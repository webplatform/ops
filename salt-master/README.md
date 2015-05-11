# Bootstrapping a new Salt Master for WebPlatform

The following set of files can be used to create a new salt master to replicate WebPlatform.org.

[Full states][wpd-salt-states] and [non private pillars][wpd-salt-pillars] are publicly available.

  [wpd-salt-states]: https://github.com/webplatform/salt-states
  [wpd-salt-pillars]: https://github.com/webplatform/salt-pillars

## Create new salt master

1. Will this deployment to use *webplatform.org* (production) or *webplatformstaging.org* (staging)?

 * Edit the *[salt-userdata.yml](./salt-userdata.yml)* to the environment you want to setup.

1. Instantiate using *python-novaclient* CLI utility and use *salt-userdata.yml*

        nova boot --image Ubuntu-14.04-Trusty \
             --user-data salt-userdata.yml \
             --key_name salt-renoirb \
             --flavor lightspeed \
             --security-groups default,all,dns,log-dest,mw-eventlog,salt-master \
             salt

1. Wait and get the new VM IP address

        nova list | grep salt

1. Copy init script to the new VM

        scp init.sh dhc-user@10.10.10.129:~

1. On the new VM

        ssh dhc-user@10.10.10.129
        sudo -s
        bash init.sh

To get a more detailed procedure, refer to the comments in [init.sh](./init.sh).

