{% if grains['nodename'] == 'salt' %}
include:
  - workbench.salt
{% endif %}

python-git:
  pkg.installed

vagrant:
  user.present:
    - createhome: False
    - groups:
      - www-data
  group.present:
    - addusers:
      - webapps
      - vagrant

/home/vagrant/workbench:
  file.symlink:
    - target: /vagrant
    - makedirs: True

Remove stuff we dont need:
  pkg.purged:
    - pkgs:
      - puppet
      - puppet-common
      - chef
      - chef-zero
