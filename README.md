# WebPlatform Infrastructure workbench

This repository contains tools to help maintain our infrastructure.


## [Kanban dashboard][kanban-dashboard]

Infrastructure work items are hosted in this [repository issue tracker][ops-issues],
you can [visualize their status and how they relate to each other in this **kanban board**][kanban-dahsboard].

Here is a screenshot of how it looks like.
[Notes about how its organized are published in this wiki page][screenshot-operations-dashboard].

![Screenshot of WebPlatform’s Kanban board](https://static.webplatform.org/w/public/6/64/20150114-Operations-dashboard.png)

[Access the **Kanban dashboard**][kanban-dashboard]


## Building a **salt master**

The main component of WebPlatform infrastructure is a VM called `salt` which is used as a server to launch every maintenance task and also as a SSH jump box.

While *the salt master* is the most important component of WebPlatform’s infrastructure,
the server is made in a way that we lose the server at any time and still be able to build a new one from scratch.
In order to achieve this, we scattered in specialized *git* repositories every bits and pieces that runs the system.

For more detail, refer to [The Salt Master][the-salt-master] document in WebPlatform’s docs pages.

The **[salt-master][salt-master-dir]** folder of this repository contains the scripts to create it.

[Review the **salt-master** code][salt-master-dir]


## Configuration workspace sandbox "Vagrant Sandbox"

While [the salt-master][the-salt-master] is the most important asset in a deployment,
development work should ideally be done from either a staging environment on an OpenStack project, or from a Vagrant workspace.

The [**vagrant-sandbox**][vagrant-sandbox-dir] should provide the workspace to build locall VMs and work on server configuration.

[Review the **vagrant-sandbox** code][vagrant-sandbox-dir]


  [the-salt-master](https://docs.webplatform.org/wiki/WPD:Infrastructure/architecture/The_salt_master)
  [ops-issues](https://github.com/webplatform/ops/issues)
  [kanban-dashboard](http://webplatform.github.io/ops/)
  [screenshot-operations-dashboard](https://docs.webplatform.org/wiki/File:20150114-Operations-dashboard.png)
  [salt-master-dir](./salt-master/)
  [vagrant-sandbox-dir](./vagrant-sandbox/)

