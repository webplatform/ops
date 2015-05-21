# WebPlatform Infrastructure workbench

This repository contains tools to help maintain our infrastructure.


## [Kanban dashboard][kanban-dashboard]

Infrastructure work items are hosted in this [repository issue tracker][ops-issues],
you can visualize their status and how they relate to each other.

Issues are displayed in a 4 columns table, each column describe the issue’s status:

* new,
* set aside for now,
* planned to work soon
* working on it
* done

Here is a screenshot of how it looks like.
[Notes about how its organized are published in this wiki page][screenshot-operations-dashboard].

![Screenshot of WebPlatform’s Kanban board](https://static.webplatform.org/w/public/6/64/20150114-Operations-dashboard.png)

### Screenshot legend

* **1,2,3,4,5**: Columns defines where the task is at (working, done, etc.)
* **1**: is where EVERY new issues goes. Waiting to be prioritized.
* **2**: is where we put tasks that we decided we set for later.
* **3,4,5**: Columns  represent tasks that are planned to be worked on during the current iteration
* **4**: Task on top has more priority than the one below. This is most true in the case of the "Working" column.
* **6**: Shows the picture of the person who was assigned to the task
* **7**: Shows the GitHub repo issue number. You can click on it to get to the issue on GitHub
* **8**: Once the task is in the "Done" column we have to close it. Note that we could also do "comment and close" directly in GitHub. Which would make a "Archive" button like we see at 9
* **9**: To hide from view the task. Its useful so we can visualize what’s been done so far and discuss whether or not we agree its completed.
* **10**: Each task can have labels with color codes
* **11**: We can link other GitHub repos (e.g. the home page repo) to the ops dashboard. That way we can see tasks in other repos all in one place. We can recognize them by the small color code on the side of the card. We can refer to them by writing the GitHub issue notation. Note the "#12", it refers to "[https://github.com/webplatform/www.webplatform.org/issues/12 webplatform/www.webplatform.org#12]" in GitHub link reference notation
* **12**: if a task cannot be done, we can flag it as "blocked", see the "x" on the side of the card

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
  [kanban-dashboard]: http://webplatform.github.io/ops/ "WebPlatform Operations Kanban dashboard"
  [screenshot-operations-dashboard]: https://docs.webplatform.org/wiki/File:20150114-Operations-dashboard.png
  [salt-master-dir]: ./salt-master/
  [vagrant-sandbox-dir]: ./vagrant-sandbox/

