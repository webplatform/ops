{% set repos = salt['pillar.get']('workbench:gitfs_remotes').items() %}

/etc/salt/minion.d/workbench-docker.conf:
  file.managed:
    - source: salt://workbench/files/salt/docker.conf

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

{% for slug,r in repos %}
{#
 # Reminder:
 #
 # r.items() looks like this:
 #
 #     [('origin', 'git@github.com:webplatform/salt-basesystem.git'), ('upstram', 'https://github.com/webplatform/salt-basesystem.git')]
 #
 # r looks like this:
 #
 #     {'origin': 'git@github.com:webplatform/salt-basesystem.git', 'upstram': 'https://github.com/webplatform/salt-basesystem.git'}
 #
 #}
Clone {{ slug }} into Workbench formula repos directory:
  git.latest:
    - name: {{ r.upstream }}
    - rev: {{ r.branch|default('master') }}
    - target: /srv/workbench-repos/states/{{ slug }}
    - unless: test -d /srv/workbench-repos/states/{{ slug }}/.git
    - remote_name: upstream
    - user: vagrant
{% if r.origin is defined %}
  cmd.run:
    - name: git remote add origin {{ r.origin }}
    - unless: grep -q -e 'remote "origin' .git/config
    - cwd: /srv/workbench-repos/states/{{ slug }}
    - user: vagrant

Add {{ slug }} entry in Workbench salt-master file_roots:
  cmd.run:
    - name: echo "    - /srv/workbench-repos/states/{{ slug }}" >> /etc/salt/master
    - unless: grep -q -e "{{ slug }}" /etc/salt/master
{% endif %}

{% endfor %}
