#!/bin/bash

set -e

#
# Bootstrapping a new WebPlatform salt master (step 2)
#
# *The packages we share accross the infrastructure*
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

if [ ! -f "/srv/ci-dreamobjects.sh" ]; then
    echo "Cannot find ci-dreamobjects, did you run state.highstate yet?"
    exit 1
fi

cd /srv

if [ ! -d "/srv/code/packages" ]; then
  echo "About to download all the packages in DreamObject wpd-packages bucket"
  . ci-dreamobjects.sh
  mkdir -p code/packages
  cd code/packages
  swift list wpd-packages > filesList
  while read FILE; do swift download wpd-packages $FILE --skip-identical; done < filesList
  rm filesList
fi

if [ -d "/srv/code/packages" ]; then
  chown -R nobody:deployment /srv/code/packages
fi

if [ -d "/srv/code/packages/auth-server/dists" ]; then
  mkdir -p /srv/code/auth-server
  cp -r /srv/code/packages/auth-server/dists /srv/code/auth-server/dists
  chown -R nobody:deployment /srv/code/auth-server
fi

if [ -d "/srv/code/packages/notes-server/dists" ]; then
  mkdir -p /srv/code/notes-server
  cp -r /srv/code/packages/notes-server/dists /srv/code/notes-server/dists
  chown -R nobody:deployment /srv/code/notes-server
fi

echo ""
echo "Extracting our SSL certificates, you will be prompted a passphrase"
gpg certificates.tar.gz.gpg
tar xfz certificates.tar.gz

echo ""
echo "Step 2 of 3 completed!"
echo ""
echo "Assuming you have a user foo, with SSH keys setup in highstate, run:"
echo "  RUNAS=${SUDO_USER} bash /srv/ops/salt-master/code.sh"
echo ""

exit 0
