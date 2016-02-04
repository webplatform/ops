# WebPlatform Infrastructure workbench

This repository contains tools to help maintain our infrastructure.

If you want to get quick access to operations related links,
you are invited to use [the **Operations start page**][ops-homepage] as a start page for your browser.



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

Each column content can be hidden to reduce visual noise by clicking on the minus symbol at the top

* `1, 2, 3, 4, 5`: Columns defines where the task is at (working, done, etc.)
* `1`: is where EVERY new issues goes. Waiting to be prioritized.
* `2`: is where we put tasks that we decided we set for later.
* `3, 4, 5`: Columns represent tasks that are planned to be worked on during the current iteration
* `4`: Task on top has more priority than the one below. This is most true in the case of the "Working" column.
* `6`: Shows the picture of the person who was assigned to the task
* `7`: Shows the GitHub repo issue number. You can click on it to get to the issue on GitHub
* `8`: Once the task is in the "Done" column we have to close it. Note that we could also do "comment and close" directly in GitHub.
    Which would make a "Archive" button like we see at 9
* `9`: To hide from view the task. Its useful so we can visualize what’s been done so far and discuss
*   whether or not we agree its completed.
* `10`: Each task can have labels with color codes
* `11`: We can link other GitHub repos (e.g. the home page repo) to the ops dashboard. 
*   That way we can see tasks in other repos all in one place. We can recognize them by the small color code on the side of the card.     We can refer to them by writing the GitHub issue notation. Note the "#12", it refers to "webplatform/www.webplatform.org#12" 
    in GitHub link reference notation
* `12`: if a task cannot be done, we can flag it as "blocked", see the "x" on the side of the card

[Access the **Kanban dashboard**][kanban-dashboard]



## Building a **salt master**

The main component of WebPlatform infrastructure is a VM called `salt` answering from **salt.webplatform.org**
which is used as a server to launch every maintenance task and also as a SSH jump box.

While *the salt master* is the most important component of WebPlatform’s infrastructure,
the server is made in a way that we lose the server at any time and still be able to build a new one from scratch.

In order to achieve this, we scattered in specialized *git* repositories every bits and pieces that runs the system.

For more detail, refer to [The Salt Master][the-salt-master] document in WebPlatform’s docs pages.

The **[salt-master][salt-master-dir]** folder of this repository contains the scripts to create it.

[Review the **salt-master** code][salt-master-dir]



## Vagrant Workbench; a *salt master* state development sandbox

Our [salt-states][salt-states-repo] scripts supports deployment of the site
without taking into account the live site.

While it spossible to work on any component of the site from the salt master,
its preferable to be able to work on configuration scripts without any possibility to impact the live site.

Ideally, we should do development work either a staging environment (i.e. *webplatformstaging.org*)
on an OpenStack project, or from a Vagrant VM.

The [**vagrant workbench**][vagrant-workbench-dir] AND [**vagrant minions**][vagrant-minions-dir]
allows you work on salt states within a set of Vagrant VMs.

With both repositories you get everything you need to have your own salt master, and an utility
to add minions by editing entries in [minions.yml][vagrant-minions-yml].

[Review the **vagrant-workbench**][vagrant-workbench-dir] and [**vagrant-minions**][vagrant-minions-dir] sub-projects.


  [the-salt-master]: https://docs.webplatform.org/wiki/WPD:Infrastructure/architecture/The_salt_master "Salt Master design document"
  [ops-issues]: https://github.com/webplatform/ops/issues "WebPlatform Operations issue tracker"
  [kanban-dashboard]: https://huboard.com/webplatform/ops/#/?repo=%5B%22ops%22%5D "WebPlatform Operations dashboard"
  [ops-homepage]: http://webplatform.github.io/ops/ "WebPlatform Operations Homepage"
  [screenshot-operations-dashboard]: https://docs.webplatform.org/wiki/File:20150114-Operations-dashboard.png
  [salt-master-dir]: ./salt-master/
  [vagrant-workbench-dir]: ./vagrant-workbench/
  [salt-states-repo]: https://github.com/webplatform/salt-states
  [vagrant-minions-yml]: ./vagrant-minions/minions.yml.dist
  [vagrant-minions-dir]: ./vagrant-minions/
