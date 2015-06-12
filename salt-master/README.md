# Bootstrapping a new Salt Master for WebPlatform

The following set of files can be used to create a new salt master to replicate WebPlatform.org.

[Full states][wpd-salt-states] and [non private pillars][wpd-salt-pillars] are publicly available.

  [wpd-salt-states]: https://github.com/webplatform/salt-states
  [wpd-salt-pillars]: https://github.com/webplatform/salt-pillars

## Create new salt master

1. Will this deployment to use *webplatform.org* (production) or *webplatformstaging.org* (staging)?

 * Edit the *[salt-userdata.yml](./salt-userdata.yml)* to the environment you want to setup.

1. Instantiate using *python-novaclient* CLI utility and use *[salt-userdata.yml](./salt-userdata.yml)*

        nova boot --image Ubuntu-14.04-Trusty \
             --user-data salt-userdata.yml \
             --key_name salt-renoirb \
             --flavor lightspeed \
             --security-groups default,salt-master \
             salt

1. Wait and get the new VM IP address

        nova list | grep salt

1. Copy init script to the new VM

        scp init.sh dhc-user@10.10.10.129:~

1. **IMPORTANT**, in order to access private data make sure **source.webplatform.org** gitolite config has your **salt-master SSH key**.

  * Ask an administrator to add your *salt-master SSH key* in `git@source.webplatform.org:gitolite-admin.git`
  * Access to the group `@wpdci` is enough for read-only actions

  **ABOUT YOUR SSH KEYS** Note that its strongly recommended that you don’t use your OWN main SSH key,
  but that you create a passphrase protected one specifically to work on our servers.
  One per environment.

1. Make sure your new VM has your *salt-master SSH key**.

  Scripts in this folder expects the file in the new VM as `/home/dhc-user/.ssh/id_rsa*` explicitly.
  Format  doesn’t matter, as long as **source.webplatform.org** has your key!

        scp -r .ssh dhc-user@10.10.10.129:~


1. On the new VM

        ssh dhc-user@10.10.10.129
        sudo mkdir -p /srv/private
        sudo chown dhc-user:dhc-user /srv/private
        sudo salt-call --log-level=quiet --local git.config_set setting_name=credential.helper setting_value="cache --timeout=3600" is_global=True user="dhc-user"
        git clone -b 201506-refactor https://gitlab.w3.org/webplatform/salt-pillar-private.git /srv/private
        sudo -s
        RUNAS=dhc-user GROUP=dhc-user bash init.sh

  To get a more detailed procedure, refer to the comments in [init.sh](./init.sh).

