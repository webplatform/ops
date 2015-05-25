{% set repos = salt['pillar.get']('workbench:gitfs_remotes').items() %}

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

/home/vagrant/workbench-formula-repos:
  file.symlink:
    - target: /vagrant/salt/workbench-repos
    - makedirs: True

Copy around the grains file for vagrant-minions to use:
  cmd.run:
    - name: cp /etc/salt/grains /vagrant/.grains
    - creates: /vagrant/.grains
    - onlyif: test -f /etc/salt/grains

{% for slug,r in repos %}
{#
 # Reminder:
 #
 # r.items() looks like this:
 #
 #     [('origin', 'git@github.com:webplatform/salt-basesystem.git'), ('upstream', 'https://github.com/webplatform/salt-basesystem.git')]
 #
 # r looks like this:
 #
 #     {'origin': 'git@github.com:webplatform/salt-basesystem.git', 'upstream': 'https://github.com/webplatform/salt-basesystem.git'}
 #
 #}
Clone {{ slug }} into Workbench formula repos directory:
  git.latest:
    - name: {{ r.origin }}
    - rev: {{ r.branch|default('master') }}
    - target: /srv/workbench-repos/states/{{ slug }}
    - unless: test -d /srv/workbench-repos/states/{{ slug }}/.git
    - user: vagrant
    - identity: /home/vagrant/.ssh/id_rsa
{% if r.upstream is defined %}
  cmd.run:
    - name: git remote add upstream {{ r.upstream }}
    - unless: grep -q -e 'remote "upstream' .git/config
    - cwd: /srv/workbench-repos/states/{{ slug }}
    - user: vagrant

Add {{ slug }} entry in Workbench /etc/salt/master.d/roots.conf file_roots:
  cmd.run:
    - name: echo "    - /srv/workbench-repos/states/{{ slug }}" >> /etc/salt/master.d/roots.conf
    - unless: grep -q -e "states\/{{ slug }}" /etc/salt/master.d/roots.conf
{% endif %}

{% endfor %}
# sysctl has an edge case.

