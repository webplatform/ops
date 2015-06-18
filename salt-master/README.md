# Bootstrapping a new Salt Master for WebPlatform

The following set of files can be used to create a new salt master to replicate WebPlatform.org.

[Full states][wpd-salt-states] and [non private pillars][wpd-salt-pillars] are publicly available.

  [wpd-salt-states]: https://github.com/webplatform/salt-states
  [wpd-salt-pillars]: https://github.com/webplatform/salt-pillars

## Create new cluster

All minions must be launched from its own salt master because it manages its own CloudInit userdata file
that makes the minion point to the salt master right after its done.

Besides, it can happen that if you create another salt-master and change the minion, that Cloud-Init would rewrite a config
file and point resolv.conf to the previous salt-master IP.

1. Will this deployment to use *webplatform.org* (production) or *webplatformstaging.org* (staging)?

 * Edit the *[salt-userdata.yml](./salt-userdata.yml)* to the environment you want to setup.

1. Instantiate using *python-novaclient* CLI utility and use *[salt-userdata.yml](./salt-userdata.yml)*

        nova boot --image Ubuntu-14.04-Trusty \
                  --user-data salt-userdata.yml \
                  --key_name renoirb-staging \
                  --flavor lightspeed \
                  --security-groups default,salt-master \
                  salt

  REMINDER: Make sure the `key_name` matches the deployment level you have, in this case I have two keys,
  I am using one key per deployment level.
  For example, in production the key is called "renoirb-production".

1. Wait and get the new VM IP address

        nova list | grep salt


  **IMPORTANT**, in order to access private data make sure **source.webplatform.org** gitolite config has your **salt-master SSH key**.

    * Ask an administrator to add your *salt-master SSH key* in `git@source.webplatform.org:gitolite-admin.git`
    * Access to the group `@wpdci` is enough for read-only actions

  **ABOUT YOUR SSH KEYS** Note that its strongly recommended that you don’t use your OWN main SSH key,
  but that you create a passphrase protected one specifically to work on our servers.
  One per environment.

1. Copy files to the new salt master

  If you had a vagrant-workbench running (strongly recommended, no need to work on the cloud!), you can do it like that;

        ssh staging.wpdn -L 2400:10.10.10.129:22
        scp -P 2400 -r vagrant-workbench/.ssh/ salt-master/init.sh dhc-user@localhost:~

  1. Make sure your new VM has your *salt-master SSH key**.

    Scripts in this folder expects the file in the new VM as `/home/dhc-user/.ssh/id_rsa*` explicitly.
    Format  doesn’t matter, as long as **source.webplatform.org** has your key!

            scp -r ~/.ssh/ /srv/ops/salt-master/init.sh dhc-user@10.10.10.129:~

    If you had a vagrant-workbench running, you can do it like that;

            ssh staging.wpdn -L 2400:10.10.10.129:22
            scp -P 2400 -r vagrant-workbench/.ssh/ salt-master/init.sh dhc-user@localhost:~

  1. Initialize the new salt master

            ssh dhc-user@localhost -p 2400
            RUNAS=dhc-user GROUP=dhc-user bash init.sh

  Once the three scripts in */srv/ops/salt-master/* are done, follow the instructions, we can [launch new minions](#Create new minions)


### Create new minions

Here are a few node boot commands. I generally boot them in that order.

Some VM must exist only once, below are the ones I generally summon.
To know which names are sensitive, refer to [Nodes that MUST exist](#Nodes that MUST exist) section.

From the new salt master;

    export COMMON_OPTS="--image Ubuntu-14.04-Trusty --user-data /srv/ops/userdata.txt --key_name renoirb-staging"
    nova boot $COMMON_OPTS --flavor lightspeed --security-groups default masterdb
    nova boot $COMMON_OPTS --flavor supersonic --security-groups default backup
    nova boot $COMMON_OPTS --flavor supersonic --security-groups default,mailhub mail
    nova boot $COMMON_OPTS --flavor supersonic --security-groups default monitor
    nova boot $COMMON_OPTS --flavor lightspeed --security-groups default sessions1
    nova boot $COMMON_OPTS --flavor lightspeed --security-groups default redis-alpha1
    nova boot $COMMON_OPTS --flavor lightspeed --security-groups default memcache-alpha1


## Nodes that MUST exist

Those nodes must exist with this exact name so that other VMs can do essential tasks such as backups and monitoring

### Name sensitive

* salt
* masterdb
* backup
* mail
* monitor

### Numbered friendly VMs

* appN
* dbN
* sessionsN



## Possible issues

### If you happen to be blocked by W3C GitLab, here’s a quick work around

        ssh dhc-user@10.10.10.129
        sudo mkdir -p /srv/private
        sudo chown dhc-user:dhc-user /srv/private
        sudo salt-call --log-level=quiet --local git.config_set setting_name=credential.helper setting_value="cache --timeout=3600" is_global=True user="dhc-user"
        git clone -b 201506-refactor https://gitlab.w3.org/webplatform/salt-pillar-private.git /srv/private
        sudo -s
        RUNAS=dhc-user GROUP=dhc-user bash init.sh

  To get a more detailed procedure, refer to the comments in [init.sh](./init.sh).
