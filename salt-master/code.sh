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

if [ $SUDO_USER == "vagrant" ]; then
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
chown -R nobody:deployment /srv/{salt,pillar,private,code}
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

# Will use salt-pillar/basesystem/salt.sls!
# salt-call pillar.get basesystem:salt:srv_code_repos

declare -A repos
declare -A options

repos["buggenie"]="git@github.com:webplatform/thebuggenie.git"
repos["dabblet"]="git@github.com:webplatform/dabblet.git"
repos["notes-server"]="git@github.com:webplatform/annotation-service.git"
repos["bots"]="git@source.webplatform.org:pierc.git"
repos["mailhub"]="git@source.webplatform.org:mailhub.git"
repos["webat25"]="git@source.webplatform.org:webat25.git"
repos["campaign-bookmarklet"]="git@github.com:webplatform/campaign-bookmarklet.git"
repos["compat"]="git@github.com:webplatform/compatibility-data.git"
repos["docsprint-dashboard"]="git@github.com:webplatform/DocSprintDashboard.git"
repos["www"]="git@github.com:webplatform/www.webplatform.org.git"
repos["blog"]="git@github.com:webplatform/blog-service.git"

options["buggenie"]="--branch webplatform-customizations --quiet"
options["dabblet"]="--branch webplatform-customizations --quiet"
options["notes-server"]="--quiet"
options["bots"]="--quiet"
options["mailhub"]="--quiet"
options["webat25"]="--quiet"
options["campaign-bookmarklet"]="--quiet"
options["compat"]="--quiet"
options["docsprint-dashboard"]="--quiet"
options["www"]="--quiet"
options["blog"]="--recurse-submodules --quiet"

if [ $IS_WORKBENCH == 0 ]; then
  repos["wiki"]="git@github.com:webplatform/mediawiki-core.git"
  options["wiki"]="--branch wmf/1.25wmf15 --quiet"
  #options["wiki"]="--branch 1.24wmf16-wpd --recurse-submodules --quiet"
else
  echo "We will NOT clone MediaWiki, you will have to do it yourself. Its TOO HEAVY."
fi

#salt-call --local --log-level=quiet git.config_set setting_name=user.email setting_value="hostmaster@webplatform.org" is_global=True
#salt-call --local --log-level=quiet git.config_set setting_name=user.name setting_value="WebPlatform Continuous Build user" is_global=True
#salt-call --local --log-level=quiet git.config_set setting_name=core.autocrlf setting_value=true is_global=True
salt-call --local --log-level=quiet git.config_set setting_name=core.editor setting_value=vim is_global=True

echo "We will be cloning code repositories:"

for key in ${!repos[@]}; do
    if [ "${key}" == "wiki" ]; then
      if [ ! -d "/srv/code/${key}/repo/mediawiki/.git" ]; then
        echo " * Cloning MediaWiki without dealing with gitmodules."
        mkdir -m 775 -p /srv/code/${key}/repo/mediawiki
        if [ $IS_WORKBENCH == 0 ]; then
          chown -R $RUNAS:deployment /srv/code/${key}/repo/mediawiki
        fi
        (salt-call --local --log-level=quiet git.clone /srv/code/${key}/repo/mediawiki ${repos[${key}]} opts="${options[${key}]}" user="$RUNAS")
        mkdir -m 775 /srv/code/${key}/repo/settings.d
      else
        echo " * Repo /srv/code/${key}/repo/mediawiki already cloned. Did nothing."
      fi
    else
      if [ ! -d "/srv/code/${key}/repo/.git" ]; then
        echo " * Cloning into /srv/code/${key}/repo"
        mkdir -m 775 -p /srv/code/${key}
        if [ $IS_WORKBENCH == 0 ]; then
            chown -R $RUNAS:deployment /srv/code/${key}
        fi
        (salt-call --local --log-level=quiet git.clone /srv/code/${key}/repo ${repos[${key}]} opts="${options[${key}]}" user="$RUNAS")
      else
        echo " * Repo in /srv/code/${key}/repo already cloned. Did nothing."
      fi
    fi
done

if [ $IS_WORKBENCH == 0 ]; then
  chown -R nobody:deployment /srv/code/
  find /srv/code -type f -exec chmod g+w {} \;
  find /srv/code -type d -exec chmod g+w {} \;
  find /srv/code -type d -exec chmod g+x {} \;
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
