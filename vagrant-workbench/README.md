# Vagrant Workbench

This directory contains scripts to work in a [Vagrant][vagrant-site] VM and replicate the same
environment we have in production on the [salt master][the-salt-master].

It should allow you to completely recreate a cluster like we run on www.webplatform.org and
allow you to work on scripts, and commit changes, so that you can work without impacting production.

While its also possible to work from production in folders such as `/srv/salt/`, `/srv/pillar/`
and `/srv/private/`, some other configuration files can't be edited at all.

Those we can't edit are the ones managed by through [Salt's `gitfs` subsystem][gitfs-walkthrough]
which allows us to clone and sync configuration automatically.

This workspace therefore allows us to have every depenency pulled as simple git clones
so we can work on them locally and push them upstream.


## Use

The `Vagrantfile` of this folder creates a Vagrant VM called `salt`, but a simple `vagrant up`
will not make it a fully fledged salt master. The Vagrantfile provides a basic VM
from which we can run the same scripts we use in production to create [our *salt master*][the-salt-master].

For this, you’ll have to launch manually the [salt-master init script][salt-master-init].

The reason of this is that this workbench provides scripts to have Vagrant VMs,
while keeping the same steps we do in production once we have VMs to work with.


### Vagrant plugins

Assuming you already have [Vagrant installed][vagrant-site] installed on your local machine,
you can use the following plugins.

    vagrant plugin install vagrant-salt
    vagrant plugin install vagrant-vbguest
    vagrant plugin install vagrant-cachier

Note that only `vagrant-salt` plugin is mandatory. Others helps to speed things up.


### Before firing up Vagrant

Make sure your have your public and private keys copied into the `.ssh/` folder,
and make sure they are accessible as `.ssh/id_rsa` and `.ssh/id_rsa.pub`.

Notice that the files MUST be found exacly with this name because other scripts will
expect them and you'll get errors.

*Tip*, the `.ssh/` is in `.gitignore` so that you can keep a copy without
worries of commiting them by mistake.


### Starting things up

Launch the VM;

    vagrant up

Notice that the Vagrantfile doesn’t call `highstate` automatically.

That’s because we want to rebuild VMs as quickly as possible and
building a salt master takes some time and has many intricate steps.

The other reason is that we'll use the same script
(i.e. [what's in sibling salt-master/ folder][salt-master-init]) that we use in production.

Once the VM is booted, get in, and launch the initialization process.

From your host, use Vagrant to get into the VM;

    vagrant ssh

Make sure the salt accepted itself;

    sudo salt-key

You should see salt in "Accepted Keys" list, otherwise;

    sudo salt-key -y -A


### First `highstate`

The first `state.highstate` should run from the basic states in `salt/states/workbench/` which basically
set the workbench by cloning all repositories for us.

    sudo salt-call state.highstate

If you already ran a full state and destroyed a Vagrant VM,
you can skip directly to the next step at [Work on salt states](#Work on salt states)

**TIP** Once the first bootup is over, you should have a file in `/vagrant/.ip` with an IP address.
  This is the file the other VMs in `[../vagrant-minions/][vagrant-minions-dir]` will read from.

If you see one failure, don’t worry, its because the workspace state expects basesystem to be applied and it isn’t. yet.

Once its done, continue with [Work on salt states](#Work on salt states).


## Work on salt states

By default the default steps of this directory `Vagrantfile` only creates an empty VM to start from.

The reason is that we want to have a quickly accessible basic VM to work from.

In order to have our own local [salt master][the-salt-master], we'll use the same steps we use in production
with [`salt-master/init.sh` scripts][salt-master-init].

Since we’re on Vagrant we don’t have DreamCompute’s dhc-user, we have to tell the script about it.

To do this, run the bootstrap like this;

    USER=vagrant GROUP=vagrant bash init.sh

Ignore the instructions the previous script run gave for a minute,
we'll have to run `workbench` state again to allow to go further.

    sudo salt-call state.sls workbench

This will change many things, you'll need to restart the salt-master service and be set to run `state.highstate`.

    sudo service salt-master restart
    sudo salt-call saltutil.sync_all
    sudo salt-call state.highstate

Its now time to resume procedure after `init.sh`.

    sudo -s
    cd /srv/ops/salt-master

**IMPORTANT**; the folder `/srv/ops` in the vagrant workbench VM **is NOT mounted from Vagrant, consider that folder as "read only" (!!)**.
Make sure you commit from your host machine workspace instead, **otherwise you'll lose code**.

Resume the process where we left;

    bash packages.sh




### Create minions

You can create minions locally and add them to this workbench.

With Vagrant Cachier plugin and a few Vagrant VMs you could replicate completely WebPlatform servers
without needing to run it on DreamCompute, AWS or DigitalOcean.

To do so, follow up directions in [../vagrant-minions/ folder][vagrant-minions-dir]


## Create packages

### Install Docker to compile containers

Notice that you could also create a local Vagrant VM that you A
a node that contains the name `upstream` in its name, and use t

If your system uses Docker to run containers, you can use the [docker-formula][docker-formula] on your servers
but also you could need it while working on your vagrant box.

Notice that if you’re using Mac OS X and use Docker, you are most likely using [*boot2docker*][boot2docker];
which is basically what this is about. The difference here is that we want to run containers in the same way we would in production.

To use Vagrant within the Vagrant Workbench, make sure you first ran the inital steps, then;

    sudo salt-call state.sls workbench.docker-builder

Since this will add kernel modules, you’ll have to reboot the Vagrant box.

Once rebooted;

Check if you have `aufs` enabled;


In production, we run every processes, including Docker, as the user "webapps".
To do such manipulation you can use the `webapps` alias which switches your current shell user as the **webapps** user.

    webapps

Then, check if you get something similar to this;

    docker -D info
    ...
    Storage Driver: aufs
    ...

Then you can work with Docker.

    docker pull ubuntu:trusty
    docker run -i -t ubuntu:trusty /bin/bash

You’re now inside a Vagrant VM, *inside* a Docker container!

    root@e3a7be5a2d3b:/# ps
    PID TTY   TIME      CMD
      1 ?     00:00:00  bash
     17 ?     00:00:00  ps


### Build a pip package for quick deployment using fpm

If you want to skip any dependency to building pip/python package at setup time for a new VM,
you can do the following from the workbench, and share this to your private repository.

Once you have your basesystem Vagrant ready, you can build your package with the following commands.

    salt-call state.sls workbench.python-builder
    salt-call state.sls workbench.fpm-builder
    mv python-docker-compose_1.1.0_all.deb /vagrant/
    fpm -s python --python-pip /usr/bin/pip -t deb docker-compose==1.1.0



## See also

This workspace has been inspired by the work of others, you should look at their work too.

### [jedmunds/vagrant][jedmunds-vagrant] Vagrantfile

His *Vagrantfile* has everything configurable in a YAML file.
While its useful, it was a bit overkill for this project.


### [elasticdog/salt-sandbox][salt-sandbox]

Workspace where you can work on Vagrant locally.



  [vagrant-site]: https://www.vagrantup.com/
  [salt-master-init]: ../salt-master/
  [vagrant-minions-dir]: ../vagrant-minions/
  [salt-sandbox]: https://github.com/elasticdog/salt-sandbox
  [docker-formula]: https://github.com/saltstack-formulas/docker-formula
  [boot2docker]: http://boot2docker.io/
  [workbench-clones]: salt/pillar/workbench/ "Pillar of all gitfs_remotes we use in production"
  [jedmunds-vagrant]: https://github.com/jedmunds/vagrant
  [elasticdog-sandbox]: https://github.com/elasticdog/salt-sandbox
  [gitfs-walkthrough]: http://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html
  [the-salt-master]: https://docs.webplatform.org/wiki/WPD:Infrastructure/architecture/The_salt_master "Salt Master design document"

