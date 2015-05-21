# Vagrant Sandbox

This directory contains scripts to work on salt states from a [Vagrant][vagrant-site] VM.

In other words, you can use this to have a local Vagrant VM with anything
you set in your servers, and use it in production as a `gitfs` formula.

While its useful to have a base system AND a workspace; make sure you don’t mix
your service from what you have everywhere.

Files in `salt/` is used **only** for Vagrant development.

This workspace is setup to be used as a local workbench,
if you want anything outside the scope of what you want on EVERY servers;
make it a separate state formula :)

If you already have [Vagrant installed][vagrant-site] installed.

Add the following plugins.

```
vagrant plugin install vagrant-salt
vagrant plugin install vagrant-vbguest

```

**NOTE** Only `vagrant-salt` is mandatory.

Then, launch the VM:

```
vagrant up
```

Notice that the Vagrantfile don’t automatically call `highstate`.
That’s because I frequently delete VMs and I’d rather have the VM being build
while I scratch my state formula prototype.

To use the base system, you´ll have then to;

```
vagrant ssh
sudo salt-call state.highstate
```


## Use alongside with Docker

If your system uses Docker to run containers, you can use the [docker-formula](https://github.com/saltstack-formulas/docker-formula) on your servers
but also you could need it while working on your vagrant box.

Notice that if you’re using Mac OS X and use Docker, you are most likely using [*boot2docker*](http://boot2docker.io/);
which is basically what this is about. The difference here is that we want to run containers in the same way we would in production.

To use Vagrant within your Vagrant sandbox, make sure you first ran [local workspace sandbox](#Use as a local workspace), then;

```
sudo salt-call state.sls vagrantsandbox.docker
```

Since this will add kernel modules, you’ll have to reboot the Vagrant box.

Once rebooted;

Check if you have `aufs` enabled;

```
docker -D info
...
Storage Driver: aufs
...
```

Then you can play with Docker.

```
docker pull ubuntu:trusty
docker run -i -t ubuntu:trusty /bin/bash
```

You’re now inside a Vagrant VM, *inside* a Docker container!

```
root@e3a7be5a2d3b:/# ps
PID TTY   TIME      CMD
  1 ?     00:00:00  bash
 17 ?     00:00:00  ps
```


## Build a pip package for quick deployment using fpm

If you want to skip any dependency to building pip/python package at setup time for a new VM,
you can do the following from the sandbox, and share this to your private repository.

Once you have your basesystem Vagrant ready, you can build your package with the following commands.

    salt-call state.sls vagrantsandbox.python
    salt-call state.sls vagrantsandbox.fpm
    apt-get install -y python-pip
    mv python-docker-compose_1.1.0_all.deb /vagrant/
    fpm -s python --python-pip /usr/bin/pip -t deb docker-compose==1.1.0


  [vagrant-site]: https://www.vagrantup.com/
