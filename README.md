# WebPlatform Infrastructure workbench

This repository contains tools to help maintain our infrastructure.

If you want to get quick access to operations related links, you are invited to use [the **Operations start page**][ops-homepage] as a start page for your browser.

## [Operations start page][ops-homepage]

A static page linking to various tools for infrastructure work.

[Access the **Operations start page**][ops-homepage]


## [Kanban dashboard][kanban-dashboard]

Infrastructure work items are hosted in this [repository issue tracker][ops-issues],
you can visualize their status and how they relate to each other.

Issues are displayed in a 4 columns table, each column describe the issue’s status:

* New ("Pending priotization")
* Set aside for now ("Later?")
* Planned to work soon ("Backlog")
* Working on it
* Done

Here is a screenshot of how it looks like.

![Screenshot of WebPlatform’s Kanban board](https://static.webplatform.org/w/public/6/64/20150114-Operations-dashboard.png)

[**Legend** and **notes** about how its organized are published in this wiki page][screenshot-operations-dashboard].

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


  [the-salt-master]: https://docs.webplatform.org/wiki/WPD:Infrastructure/architecture/The_salt_master "Salt Master design document"
  [ops-issues]: https://github.com/webplatform/ops/issues "WebPlatform Operations issue tracker"
  [kanban-dashboard]: https://huboard.com/webplatform/ops/#/?repo=%5B%22ops%22%5D "WebPlatform Operations dashboard"
  [ops-homepage]: http://webplatform.github.io/ops/ "WebPlatform Operations Homepage"
  [screenshot-operations-dashboard]: https://docs.webplatform.org/wiki/File:20150114-Operations-dashboard.png
  [salt-master-dir]: ./salt-master/
  [vagrant-sandbox-dir]: ./vagrant-sandbox/

