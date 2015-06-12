#!/bin/bash

set -e

#
# Bootstrapping a new WebPlatform salt master (step 1)
#
# *Cloning Salt configurations*
#
# This script is meant to be run only once per salt master
# so that every code dependencies are cloned and installed
# in a constant fashion.
#
# A salt master should have NO hardcoded files and configuration
# but simply be booted bootstrapped by the three following components.
#
# 1. Cloning Salt configurations (so we can salt the salt master)
# 2. The packages we share accross the infrastructure
# 3. Cloning every webplatform.org software dependencies.
#
# =========================================================================
#
# Note that you can run this bootstrapper on ANY vanilla Ubuntu 14.04 VM and
# it should work just fine. This script takes into account that you might
# might now have a master to start from. If that’s the case, make sure the
# new VM is called "salt.staging.wpdn" (or "salt.production.wpdn") in the
# `/etc/hosts` file and jump to step #5
#
# =========================================================================
#
# STEPS:
#
# From an existing salt-master, do the following;
#
# 1. Get to know the next IP address nova will give:
#
# This is useful so we can tell the new salt master to use the upcoming new
# DNS. Normally, nova rotates +1 private IP addresses. Note that you can
# get to know the IP address, and boot an empty VM from OpenStack Dashboard
# but if you are like the author, better having only shell stuff!
#
#     nova list
#
#
# 2. Edit manually `/srv/salt/salt/master.sls`
#
#     vi /srv/salt/salt/master.sls
#
# Get the `salt_master_ip:` line. Edit with the IP address you expect nova will
# give (e.g. 10.10.10.129).  Run highstate on master
#
#     salt salt state.highstate
#
# It should have updated `/srv/userdata.txt` so that the next VM will know at
# boot time that it should listen to itself as a new salt master.  Note that
# userdata is part of OpenStack and that this script is run at every reboot,
# stating that on subsequent boots to listen to itself instead of another
# IP, that most likely wont exist anymore, prevents potential
# confusion and misdirected network traffic.
#
#
# 3. Using python-novaclient, launch new future salt-master:
#
# We will have two VMs with name `salt` the new one will not have public IP
# address yet. The last step is to ask OpenStack to change the public IP
# address to the new salt master.
#
# Start the new VM:
#
#     nova boot --image Ubuntu-14.04-Trusty \
#               --user-data /srv/ops/salt-master/salt-userdata.yml \
#               --key_name renoirb \
#               --flavor lightspeed \
#               --security-groups default,salt-master \
#               salt
#
# NOTE: Adjust `key_name` with your secret key that you given in OpenStack dashboard
#       you should have on the salt master. That one is only useful among VMs you
#       control FROM the salt master. It should be available in
#       `/srv/private/pillar/sshkeys/init.sls` as its kept in source control so it
#       can replicate the same setup everywhere.
#
#
# 4. Send this bootstrapper file, get new private IP first
#
# Hopefully the new VM will have the IP address we expected at step 1
#
# If it works, after the following commands, we will resume the work on the new VM.
#
# Double check and continue like this, assuming the new VM private IP *is* ending by `129`:
#
# From current salt master:
#
#     nova list
#     scp /srv/ops/salt-master/init.sh dhc-user@10.10.10.129:~
#
# Remember ...129 (in this example) is *also* called salt. Current salt master has public
# key to be accepted on it. Once the file is moved, we can SSH to the new VM. Note that
# we have to SSH from the current salt master as its the one that already has your current
# private/public key for dhc-user already.
#
#
# 5. Launch this bootstrapper
#
# You must be on the new VM at this step. Copy to the new VM this file and you will be
# just fine.
#
# This bootstrapper will initialize everything we need:
# - Instal that node as a salt master
# - Have all states ready to be called `state.highstate` and effectively make it a salt master
# - Have all states so it can *also* pull all /srv/code repositories so it can sync code around
# - Have all scripts so it can also boot VMs
#
# Run this script
#
#    ssh dhc-user@10.10.10.129
#    sudo -s
#    RUNAS=dhc-user GROUP=dhc-user bash init.sh
#
# And go on with the show...
#
clear
cat << "WEBPLATFORM_ASCII_BANNER"


                            _    _      _    ______ _       _    __
                           | |  | |    | |   | ___ \ |     | |  / _|
                           | |  | | ___| |__ | |_/ / | __ _| |_| |_ ___  _ __ _ __ ___
                           | |/\| |/ _ \ '_ \|  __/| |/ _` | __|  _/ _ \| '__| '_ ` _ \
                           \  /\  /  __/ |_) | |   | | (_| | |_| || (_) | |  | | | | | |
                            \/  \/ \___|_.__/\_|   |_|\__,_|\__|_| \___/|_|  |_| |_| |_|


                           WebPlatform Infrastructure         CREATING A NEW SALT MASTER

WEBPLATFORM_ASCII_BANNER


echo " "
echo " "
echo "Bootstrapping a new Salt master"
echo " * Check in both OpenStack and Vagrant if we get same value for both variables; SUDO_USER: ${SUDO_USER}, RUNAS: ${RUNAS} should be the same."


declare -r SALT_BIN=`which salt-call`
declare -r DATE=`date`


if [ -z "${RUNAS}" ]; then
  echo "You must declare which user your VM initially has  e.g. RUNAS=vagrant GROUP=vagrant bash init.sh"
  exit 1
fi

if [ -z "${GROUP}" ]; then
  echo "You must declare which group your VM initially has. e.g. RUNAS=vagrant GROUP=vagrant bash init.sh"
  exit 1
fi

if [ -z "${SALT_BIN}" ]; then
  echo "Saltstack doesn’t seem to be installed on that machine"
  exit 1
fi

if [ ! -f "/home/${RUNAS}/.ssh/id_rsa" ]; then
  echo "Cannot go any further, you MUST have ssh keypair in /home/${RUNAS}/.ssh/id_rsa"
  exit 1
fi


#
# Make sure that if you change /srv/private away from using
# W3C GitLab at https://gitlab.w3.org/webplatform/salt-pillar-private.git
# The data should be coming from pillar "basesystem:salt:srv_repos:/srv/private"
#
cat << _EOF_

 This script is about cloning git repos we need.

 Some of them has sensitive data and this script will attempt to clone the
 repositories with a local SSH key.

 In order to run this script successfully, you should make sure the remotes
 we use has your key authorized.

 You can create your own keypair and add them to this script yourself.

 To generate a temporary key, run the following;

    ssh-keygen -f /home/${SUDO_USER}/.ssh/id_rsa
    cat /home/${SUDO_USER}/.ssh/id_rsa.pub
    cat /home/${SUDO_USER}/.ssh/id_rsa

 Make sure the key is installed:

   - https://gitlab.w3.org/webplatform/
   - https://github.com/webplatform/
   - git@source.webplatform.org:gitolite-admin.git


 OTHERWISE THE SCRIPT WON’T COMPLETE.


_EOF_


while true; do
    echo ""
    echo "Here is the key: "
    cat /home/${SUDO_USER}/.ssh/id_rsa.pub
    echo ""

    read -p "Do you have this public key enabled in previously described repositories? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done


grep -q -e "initial_user" /etc/salt/grains || printf "\ninitial_user: ${RUNAS}\n" >> /etc/salt/grains


#
# The file /etc/salt/minion.d/workbench.conf should ONLY be added
# via Vagrantfile. This is how we know if we want to clone formulas
# of use them as gitfs.
#
# To rework this bit, you will have to review the salt/new_master.sls
# state file. The /etc/salt/master.d/gitfs.conf content is loaded in function
# of the "biosversion" grain, if it matches "VirtualBox".
#
# For now, lets only support local formula workbench on VirtualBox VMs
#
if [ -f "/etc/salt/minion.d/workbench.conf" ]; then
  declare -r IS_WORKBENCH=1
  declare -r level='workbench'
else
  declare -r IS_WORKBENCH=0
fi

if [ ! -f "/etc/salt/minion.d/saltmaster.conf" ]; then
  clear
  echo ""
  echo "What is the deployment level of this cluster? Will it be used as the"
  echo "new production, staging, or a Salt state development workbench?"
  echo ""

  if [ $IS_WORKBENCH == 0 ]; then
    while true; do
      read -p "What is this salt-master targeted level? [staging,production]: " level
      case $level in
          staging ) break;;
          production ) break;;
          * ) echo "Only lowercase is accepted; one of [staging,production].";;
      esac
    done
  fi

  ## We are hardcoding the name "salt" here because we EXPLICTLY want that VM to be
  ## called that name.
  echo " * Making sure the /etc/hosts file has the loopback 127.0.0.1 with the name salt in it"
  sed -i "s/^127.0.1.1 $(hostname)/127.0.1.1 salt.${level}.wpdn salt/g" /etc/hosts
  grep -q -e "salt" /etc/hosts || printf "127.0.1.1 salt.${level}.wpdn salt" >> /etc/hosts
  printf "id: salt\n" > /etc/salt/minion.d/id.conf

  if [ $IS_WORKBENCH == 0 ]; then
    grep -q -e "level" /etc/salt/grains || printf "level: ${level}\n" >> /etc/salt/grains
  fi

(cat <<- _EOF_
# This salt master has been created on ${DATE}
# via webplatform/ops salt-master/init.sh script
_EOF_
) > /etc/salt/minion.d/saltmaster.conf

  echo " * Added level grain in /etc/salt/grains, set value to: ${level}"
  echo " * Created /etc/salt/minion.d/saltmaster.conf so we know its a salt-master"
else
  echo " * salt-master touchfile at /etc/salt/minion.d/saltmaster.conf already existed. Did nothing."
fi


echo " * Add debug output to the salt configuration"
(cat <<- _EOF_
log_level: debug
log_level_logfile: debug
_EOF_
) > /etc/salt/minion.d/overrides.conf


mkdir -p /srv/formulas

declare -A repos
declare -A options

repos["salt"]="https://github.com/webplatform/salt-states.git"
repos["pillar"]="https://github.com/webplatform/salt-pillar.git"
repos["formulas/basesystem"]="https://github.com/webplatform/salt-basesystem.git"

options["salt"]="--branch 201506-refactor-cleanup --quiet"
options["pillar"]="--branch 201506-refactor --quiet"
options["formulas/basesystem"]="--quiet"


echo ""
echo "Setting up some global preferences"

echo " * First, set Git to remember Git/HTTP authentication credentials to ONE hour"
# ref https://help.github.com/articles/caching-your-github-password-in-git/#platform-linux
salt-call --log-level=quiet --local git.config_set setting_name=credential.helper setting_value="cache --timeout=3600" is_global=True user="${RUNAS}"
chown -R ${RUNAS}:${GROUP} /home/${RUNAS}
#chown -R ${RUNAS}:${GROUP} /home/${RUNAS}/.gitconfig /home/${RUNAS}/.git-credential-cache


echo " * Ensure Git editor is vim"
salt-call --log-level=quiet --local --log-level=quiet git.config_set setting_name=core.editor setting_value=vim is_global=True

echo " * Set default Git user email and name"
salt-call --local --log-level=quiet git.config_set setting_name=user.email setting_value="team-webplatform-systems@w3.org" is_global=True
salt-call --local --log-level=quiet git.config_set setting_name=user.name setting_value="WebPlatform Continuous Build user" is_global=True


echo ""
echo "We will be cloning our new Salt master config repos:"


for key in ${!repos[@]}; do
    if [ ! -d "/srv/${key}/.git" ]; then
      echo " * Cloning into /srv/${key}"
      mkdir -p /srv/${key}
      chown $RUNAS:$GROUP /srv/${key}
      (salt-call --local --log-level=quiet git.clone /srv/${key} ${repos[${key}]} opts="${options[${key}]}" user="${RUNAS}" identity="/home/${RUNAS}/.ssh/id_rsa")
    else
      echo " * Repo in /srv/${key} already cloned. Did nothing."
    fi
done

echo ""
echo "Done cloning config repos"
echo ""


echo "Configuring salt master for initial highstate"
(cat <<- _EOF_

# Set in place by webplatform/ops salt-master/init.sh script, this should be overwritten once you
# make state.highstate.

pillar_roots:
  base:
    - /srv/pillar

# Let this list be appended so we can work locally
# on what is in gitfs_remotes in production.
file_roots:
  base:
    - /srv/salt
    - /srv/formulas/basesystem

_EOF_
) > /etc/salt/master.d/roots.conf

echo " * Added roots definitions"


echo " * Overriden /srv/pillar/top.sls to have only basesystem.salt for now"
printf "base:\n  salt:\n    - basesystem.salt\n" > /srv/pillar/top.sls


echo " * Restarting salt-minion and salt-master"
/usr/sbin/service salt-minion restart
/usr/sbin/service salt-master restart


if [ ! -f /etc/salt/pki/master/minions/salt ]; then
  echo " * Auto accept salt, we are going to wait 10 seconds to be sure we can accept it"
  sleep 10
  salt-key -y -a salt
else
  echo " * Auto accept salt; already done"
fi


salt-call --log-level=quiet saltutil.sync_all
echo " * Synced grains, pillars, states, returners, etc."


echo ""
echo "Launching salt.new_salt_master state..."
salt-call state.sls salt.new_master


echo "... done"


echo ""
echo "Cleaning things up:"


cd /srv/pillar
git checkout top.sls
echo " * Set back overridden /srv/pillar/top.sls file"


if [ $IS_WORKBENCH == 0 ]; then
  rm /home/${RUNAS}/.ssh/id_rsa{,.pub}
  echo " * Removed temporary SSH keys"
  if [ -d "/srv/formulas/basesystem" ]; then
    rm -rf /srv/formulas/basesystem
    echo " * Removed /srv/formulas/basesystem, we should have it in gitfs anyway"
  fi
else
  cp /etc/salt/grains /vagrant/.grains
fi

echo " * Restarting salt-minion and salt-master"
/usr/sbin/service salt-minion restart
/usr/sbin/service salt-master restart


echo " * Refreshing pillar and all the rest"
salt-call saltutil.sync_all

echo "... done"


echo ""
echo "Step 1 of 3 completed!"
echo ""


if [ $IS_WORKBENCH == 0 ]; then
  echo ""
  echo "We now have a VM, somewhere. Thats great!"
  echo ""
  echo "Next steps;"
  echo " salt-call state.highstate"
  echo " bash /srv/ops/salt-master/packages.sh"
  echo ""
else
  echo ""
  echo "We now have a Vagrant Workbench, thats great!"
  echo ""
  echo "If its the first time you build, you have to reboot, e.g."
  echo " vagrant halt"
  echo " vagrant up"
  echo ""
  echo "Next steps;"
  echo " salt-call state.highstate"
  echo " RUNAS=$RUNAS bash /srv/ops/salt-master/packages.sh"
  echo ""
fi

exit 0
