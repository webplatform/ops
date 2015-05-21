# Vagrant Workbench

This directory contains scripts to work on salt states from a [Vagrant][vagrant-site] VM.

In other words, you can use this to have a local Vagrant VM with anything you need to compile
a container, or work on salt states that are pulled from `gitfs` in production.

While its useful to work on a separate environment such as one we could deploy as `webplatformstaging.org`,
working locally with the exact configuration is better.



## Use

The `Vagrantfile` of this folder creates a Vagrant VM called `salt-workbench`,
but in order to use it as a fully fledged salt master
you’ll have to launch manually the [salt-master init script][salt-master-init].

The reason of this is that this workbench provides scripts to have Vagrant VMs,
while keeping the same steps we do in production once we have VMs to work with.

Let’s start things up now.

Assuming you already have [Vagrant installed][vagrant-site] installed on your local machine,
you’ll need a few plugins.

Namely;

    vagrant plugin install vagrant-salt
    vagrant plugin install vagrant-vbguest
    vagrant plugin install vagrant-cachier

**NOTE** Only `vagrant-salt` plugin is mandatory. Others helps to speed things up.

Launch the VM;

    vagrant up

Notice that the Vagrantfile doesn’t call `highstate` automatically.
That’s because we want to rebuild VMs as quickly as possible and building a salt master
takes some time.

The other reason is that its also ideal to have a simple VM that has the same toolchain we have in production.

Once the VM is booted, get in, and launch the initialization process.

From your host, use Vagrant to get into the VM;

    vagrant ssh
    sudo salt-key -y -A
    sudo salt-call state.highstate

Its basically adding a few helper utilities for the workbench (see blow) and
it’ll clone the salt-formulas we use in production (see [workbench clones][workbench-clones]).

If you see one failure, don’t worry, its because the workspace state expects basesystem to be applied and it isn’t. yet.

Once its done, continue with [Work on salt states](#Work on salt states).


## Work on salt states

By default the default steps of this directory `Vagrantfile` only creates an empty VM.

In order to do so, we have to use the exact steps we use to create on a Cloud Provider, but locally in a Vagrant VM.

The reason is that we want to have a quickly accessible basic VM to work from that replicates WebPlatform clusters.
In order to do so, we have to use the exact steps we use to create on a Cloud Provider, but locally.

To fully bootstrap this VM as a salt master, you’ll have to use the [`salt-master/init.sh` scripts][salt-master-init] that are in the present repository.

Then, still from the salt-workbench Vagrant VM;

    sudo service salt-minion restart
    sudo service salt-master restart
    sudo salt-call state.sls basesystem
    sudo salt-call state.highstate

From your local workspace, just copy the files in `salt-master/` manually to `salt-workbench/` (this folder) so that
the salt-workbench VM will see it in its `/vagrant` directory.

In order to start the process of creating the salt master you’ll need to have an SSH key pair available in every repository the scripts in `salt-master/*.sh` has.

You’ll have to read the script and ensure that every repository has at least one ssh key the *salt-workbench* VM 


### Create minions

You can create minions locally and add them to this workbench.

With Vagrant Cachier plugin and a few Vagrant VMs you could replicate completely WebPlatform servers
without needing to run it on DreamCompute, AWS or DigitalOcean.


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


  [vagrant-site]: https://www.vagrantup.com/
  [salt-master-init]: ../salt-master/
  [salt-sandbox]: https://github.com/elasticdog/salt-sandbox
  [docker-formula]: https://github.com/saltstack-formulas/docker-formula
  [boot2docker]: http://boot2docker.io/
  [workbench-clones]: salt/pillar/workbench/ "Pillar of all gitfs_remotes we use in production"

