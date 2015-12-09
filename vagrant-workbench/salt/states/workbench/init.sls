{# #TODO: Ordering problem, see: http://ryandlane.com/blog/2015/01/06/truly-ordered-execution-using-saltstack-part-2/
{% if grains['nodename'] == 'salt' %}
{% include "salt.sls" %}
{% endif %}
#}

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
