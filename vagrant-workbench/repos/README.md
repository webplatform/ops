# Workbench clones

This is where we either clone or download assets to build the salt master.

Once a *vagrant workbench* is fully built, you should see a README in each folders.

Here’s a summary;


## Code

This folder should have every code repository the [salt-master/code.sh][../salt-master/code.sh] script.

* **code/packages/**: is a folder we sync from DreamObjects such as SSL certificates
* **code/blog/**: the `repo/` folder contains current clone of [our blog][gh-blog-service]
* **code/bots/**: contains our fork of a Python IRC chat logger with PHP frontend now known as [Pierc][bot-original]
* **code/campaign-bookmarklet/**: the `repo/` folder contains current clone [campaign bookmarklet][gh-campaign]
* **code/compat/**: the `repo/` folder contains current clone of [compatibility-data][gh-compat] which is used by our Docs pages [to generate compatibility tables][docs-compat]
* **code/dabblet/**: the `repo/` folder contains current clone of [dabblet we use for *code.webplatform.org*][gh-dabblet]
* **code/mailhub/**: the `repo/` folder contains data from a private git repository hosted on W3C Infrastructure
* **code/notes-server/**: the `repo/` folder contains current clone of [hypothesi.is distribution][gh-annotation-service]
* **code/wiki/**: the `repo/` folder contains current clone of [MediaWiki distribution][gh-wiki]. Note that we are forking Wikimedia foundation' *wmf/\** branches, the same as they use for *wikipedia.org*
* **code/wiki/repo/mediawiki/extensions/WebPlatformMediaWikiExtensionBundle/**: is where we clone our own customizations that we commit in [webplatform/mediawiki][gh-wiki-extension]
* **code/www/**: the `repo/` folder contains current clone of [www.webplatform.org repository][gh-www]


## Formulas

This folder is where the workbench will clone every salt formulas we use.

Normally those would be called as a `gitfs_remotes` on the production salt master,
but here we’ll be able to work with them.


  [gh-blog-service]: https://github.com/webplatform/blog-service
  [gh-campaign]: https://github.com/webplatform/campaign-bookmarklet
  [gh-compat]: https://github.com/webplatform/compatibility-data
  [gh-dabblet]: https://github.com/webplatform/dabblet
  [gh-ds]: https://github.com/webplatform/DocSprintDashboard
  [gh-annotation-service]: https://github.com/webplatform/annotation-service
  [gh-wiki]: https://github.com/webplatform/mediawiki-core
  [gh-wiki-extension]: https://github.com/webplatform/mediawiki
  [bot-original]: https://classam.github.io/pierc
  [docs-compat]: http://docs.webplatform.org/wiki/Template:Compatibility
  [gh-www]: https://github.com/webplatform/www.webplatform.org
