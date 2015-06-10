# Vagrant Workbench

This directory contains scripts to work in a [Vagrant][vagrant-site] VM and replicate the same
environment we have in production on the [salt master][the-salt-master] to run
[www.webplatform.org][webplatform] :squirrel:.

While its possible to work through SSH to a *production*/*staging* *salt-master* and edit
configuration management files in folders such as `/srv/salt/`, `/srv/pillar/` and `/srv/private/`,
there are some other files that we can’t edit at all.

This is because we also rely *salt formulas* that are managed by [Salt's `gitfs` subsystem][gitfs-walkthrough]
which allows us to clone and sync configuration automatically.
Useful for automation, but we can’t work on them.

This workspace allows us to pull in every depenency through git so we can work and test them
them locally.


## Use

The `Vagrantfile` of this folder creates a Vagrant VM called `salt`, but a simple `vagrant up`
will not make it a fully fledged salt master.

Once you’ve done the intial boot up, you’ll be able to run [salt-master init script][salt-master-init],
which is the same we use in production, so we get a [our own Vagrant-ed *salt master*][the-salt-master].


### Vagrant plugins

Assuming you already have [Vagrant installed][vagrant-site] installed on your host machine,
you can use the following plugins.

    vagrant plugin install vagrant-salt
    vagrant plugin install vagrant-vbguest
    vagrant plugin install vagrant-cachier

Note that only `vagrant-salt` plugin is mandatory. Others helps to speed things up.


### Vagrant is configured to use NFS mounts

Make sure your operating system supports NFS mouts.

You can refer to [Vagrant synced-folders NFS mounts section][vagrant-synced-nfs] section.

Also, if you want to get rid of **NFS mount password** at every `vagrant up`, you’ll see instructions in *Vagrant synced-folders NFS mounts* page.


### Before firing up Vagrant

Make sure your have your public and private keys copied into the [.ssh/](./.ssh/) folder,
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

From your host, use Vagrant to get into the VM;

    vagrant ssh

**TIP** Once the first bootup is over, you should have a file in `/vagrant/.ip` with an IP address.
  This is the file the other VMs in [**../vagrant-minions/** folder](../vagrant-minions/) will read from.

By default the default steps of this directory `Vagrantfile` only creates an empty VM to start from.

In order to have our own local [salt master][the-salt-master], we'll use the same steps we use in production
with [`salt-master/init.sh` scripts][salt-master-init].

Since we’re on Vagrant we don’t have DreamCompute’s `dhc-user`, we have to tell the script about it.

To do this, run the bootstrap like this;

    sudo -s
    RUNAS=vagrant GROUP=vagrant bash init.sh

This should ensure we clone every git repository in a consistent in every environment.

Also, in the case of a Vagrant VM managed by VirtualBox, it’ll take care of copying files so that the `vagrant-minions/` knows how to find the salt master.

We are ready for the highstate;

    salt-call state.highstate

If you see erros *highstate* result output, you might have to run the command another time. It can be an ordering bug in the [state repository][salt-states].

Its now time to resume procedure after `init.sh`.

    cd /srv/ops/salt-master

**IMPORTANT** :warning: the `/srv/ops/` fold inside the VM **is NOT mounted from Vagrant, consider that folder as "read only" :warning:**.
Make sure you commit from your host machine workspace instead, **otherwise you'll lose code**.

Resume the process where we left;

Note that if you already ran the workspace and trashed the VM, you don’t need to do it again. Otherwise;

    bash packages.sh
    RUNAS=vagrant bash code.sh



### Create minions

You can create minions locally and add them to this workbench.

With Vagrant Cachier plugin and a few Vagrant VMs you could replicate completely WebPlatform servers
without needing to run it on DreamCompute, AWS or DigitalOcean.

To do so, follow up directions in [../vagrant-minions/ folder](../vagrant-minions/).


## Create packages

### Install Docker to compile containers

Notice that you could also create a local Vagrant VM that you A
a node that contains the name `upstream` in its name, and use t

If your system uses Docker to run containers, you can use the [docker-formula][docker-formula] on your servers
but also you could need it while working on your vagrant box.

Notice that if you’re using Mac OS X and use Docker, you are most likely using [*boot2docker*][boot2docker];
which is basically what this is about. The difference here is that we want to run containers in the same way we would in production.

To use Vagrant within the Vagrant Workbench, make sure you first ran the inital steps, then;

    sudo salt-call state.sls workbench.builder-docker

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

    salt-call state.sls workbench.builder-python
    salt-call state.sls workbench.builder-fpm
    mv python-docker-compose_1.1.0_all.deb /vagrant/
    fpm -s python --python-pip /usr/bin/pip -t deb docker-compose==1.1.0



## See also

This workspace has been inspired by the work of others, you should look at their work too.

### [jedmunds/vagrant][jedmunds-vagrant] Vagrantfile

His *Vagrantfile* has everything configurable in a YAML file.
While its useful, it was a bit overkill for this project.


### [elasticdog/salt-sandbox][salt-sandbox]

Workspace where you can work on Vagrant locally.


### [purpleidea/oh-my-vagrant][oh-my-vagrant]

Vagrant workspace where you can configure Docker, Puppet and other providers.


### Insightful blog posts

* [Don’t copy your *Vagrantfile*][zigomir-blog-post]
* [Human Keyboard; SaltStack VirtualBox Vagrant workspace][humankeyboard-saltstack-virtualbox-vagrant]

  [vagrant-site]: https://www.vagrantup.com/
  [salt-master-init]: ../salt-master/
  [salt-sandbox]: https://github.com/elasticdog/salt-sandbox
  [docker-formula]: https://github.com/saltstack-formulas/docker-formula
  [boot2docker]: http://boot2docker.io/
  [workbench-clones]: salt/pillar/workbench/ "Pillar of all gitfs_remotes we use in production"
  [jedmunds-vagrant]: https://github.com/jedmunds/vagrant
  [elasticdog-sandbox]: https://github.com/elasticdog/salt-sandbox
  [gitfs-walkthrough]: http://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html
  [the-salt-master]: https://docs.webplatform.org/wiki/WPD:Infrastructure/architecture/The_salt_master "Salt Master design document"
  [vagrant-synced-nfs]: http://docs.vagrantup.com/v2/synced-folders/nfs.html
  [webplatform]: https://www.webplatform.org/
  [zigomir-blog-post]: http://blog.zigomir.com/vagrant/dry/vagrantfile/ruby/2015/01/08/dont-copy-your-vagrantfile.html
  [oh-my-vagrant]: https://github.com/purpleidea/oh-my-vagrant
  [humankeyboard-saltstack-virtualbox-vagrant]: http://humankeyboard.com/saltstack/2014/saltstack-virtualbox-vagrant.html
  [salt-states]: https://github.com/webplatform/salt-states

