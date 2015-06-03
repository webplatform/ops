# Vagrant Workbench Minions

Define a list of VMs you want to run and boot them in Vagrant.
The *vagrant-workbench "salt master"* will take care of them.

## Use

1. Make sure you booted and completed steps of [vagrant-workbench](../vagrant-workbench/) salt master
2. Copy and edit **minions.yml**, the [minions.yml.dist](./minions.yml.dist) should be of help for the format to use.
3. Boot it up; `vagrant up`
4. On the **salt** *vagrant workbench* VM, you'll see the machines waiting to be added to the salt master.

## Use on another machine

If you have more than the computer you work from available to you, you can make them use your *vagrant-workbench* using the following procedure.

The only limitation is that you should make sure that the `[minions.yml](./minions.yml.dist)` has no `mounts` entries,
otherwise you would need to clone them manually.

To do this, make sure the other machine(s);

* Has access to the same local network (i.e. behind same router)
* Has [Vagrant][vg] and [VirtualBox][vb] installed
* [VirtualBox has *host only* networking enabled][vb-hostonly]
* Has a copy of this repository, with;
 * The file `../vagrant-workbench/.ip` containing with your main computer LAN IP (e.g. `192.168.0.102`). It might differ from what your main computer has; Port-forwarding should be in place.
 * Create a file in `../vagrant-workbench/.grains` with the contents: `level: workbench`

  [vg]: https://www.vagrantup.com/
  [vb]: https://www.virtualbox.org/
  [vb-hostonly]: https://blogs.oracle.com/fatbloke/entry/virtualbox_vms_with_multiple_vnics
