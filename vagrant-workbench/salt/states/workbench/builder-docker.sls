# ref: https://github.com/saltstack-formulas/docker-formula
{%- set kernelrelease = salt['grains.get']('kernelrelease') %}

include:
  - .
  - docker
  - basesystem

Docker linux-kernel deps:
  pkg.installed:
    - pkgs:
      - linux-image-extra-{{ kernelrelease }}
      - aufs-tools
  cmd.run:
    - name: modprobe aufs
    - unless: modinfo aufs > /dev/null 2>&1

# ref: http://docs.docker.com/installation/ubuntulinux/#create-a-docker-group
docker:
  group.present:
    - system: True
    - addusers:
      - webapps
      - vagrant
    - require:
      - user: webapps

