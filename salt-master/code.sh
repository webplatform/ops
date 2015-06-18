#!/bin/bash

set -e

#
# Bootstrapping a new WebPlatform salt master (step 3)
#
# *Cloning every webplatform.org software dependencies*
#
# This script is meant to be run only once per salt master
# so that every code dependencies are cloned and installed
# in a constant fashion.
#
# A salt master should have NO hardcoded files and configuration
# but simply be booted bootstrapped by the three following components.
#
# 1. Salt configurations (so we can salt the salt master)
# 2. The packages we share accross the infrastructure
# 3. Cloning every webplatform.org software dependencies.
#

if [ -z "${RUNAS}" ]; then
  echo "You must declare which user you are using that has valid ssh keys  e.g. RUNAS=renoirb bash code.sh"
  exit 1
fi

if [ -f "/etc/salt/minion.d/workbench.conf" ]; then
  declare -r IS_WORKBENCH=1
else
  declare -r IS_WORKBENCH=0
fi

declare -r SALT_BIN=`which salt`

if [ -z "${SALT_BIN}" ]; then
  echo "This machine isn’t a salt master"
  exit 1
fi

if [ $IS_WORKBENCH == 0 ]; then
echo "Setting file ownership on salt master checkouts"
chmod g+w /srv/code
chown -R renoirb:deployment /srv/{salt,pillar,private,code}
find /srv/salt -type f -exec chmod 664 {} \;
find /srv/pillar -type f -exec chmod 664 {} \;
find /srv/private -type f -exec chmod 660 {} \;
find /srv/salt -type d -exec chmod 775 {} \;
find /srv/pillar -type d -exec chmod 775 {} \;
find /srv/private -type d -exec chmod 770 {} \;
chmod 755 /srv/salt/_grains/*.py
fi


echo "About to clone code..."


cd /srv/code


# Should we do that too, unsure yet
#salt-call --local --log-level=quiet git.config_set setting_name=core.autocrlf setting_value=true is_global=True


echo ""
echo "We will be cloning code repositories:"
salt-call state.sls code


if [ $IS_WORKBENCH == 0 ]; then
  chown -R renoirb:deployment /srv/code/
  find /srv/code -type f -exec chmod g+w {} \;
  find /srv/code -type d -exec chmod g+w {} \;
  find /srv/code -type d -exec chmod g+x {} \;
  find /srv/code/packages/certificates -type f -exec chmod 644 {} \;
fi


echo ""
echo "Step 3 of 3 completed!"
echo ""
if [ $IS_WORKBENCH == 0 ]; then
  echo "Last step, install deployable code dependencies:"
  echo "  - As your normal user:"
  echo "      cd /srv/code/wiki/repo/mediawiki/; git submodule update --init --recursive"
  echo ""
  echo "... MediaWiki submodules are too heavy to run in this script."
else
  echo "VAGRANT Workbench difference warning:"
  echo ""
  echo "Things should be very close to production, in this script we ignored file ownership chnages."
  echo "It means that you might have to try in a deployment on OpenStack to make sure your rights dont break stuff."
  echo ""
  echo "ALSO; we didn't clone MediaWiki. Its too heavy."
  echo "This part should be adressed differently or we should rework how we deploy MediaWiki."
fi
exit 0
