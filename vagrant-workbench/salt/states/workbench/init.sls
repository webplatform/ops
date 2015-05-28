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

Copy around the grains file for vagrant-minions to use:
  cmd.run:
    - name: cp /etc/salt/grains /vagrant/.grains
    - creates: /vagrant/.grains
    - onlyif: test -f /etc/salt/grains