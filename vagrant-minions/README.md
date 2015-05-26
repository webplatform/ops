# Vagrant Workbench Minions

Define a list of VMs you want to run and boot them in Vagrant.
The *vagrant-workbench "salt master"* will take care of them.

## Use

1. Make sure you booted and completed steps of [vagrant-workbench](../vagrant-workbench/) salt master
2. Copy and edit **minions.yml**, the [minions.yml.dist](./minions.yml.dist) should be of help for the format to use.
3. Boot it up; `vagrant up`
4. On the **salt** *vagrant workbench* VM, you'll see the machines waiting to be added to the salt master.

