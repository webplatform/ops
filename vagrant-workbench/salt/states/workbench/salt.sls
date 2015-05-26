{% set repos = salt['pillar.get']('workbench:gitfs_remotes').items() %}

/home/vagrant/workbench-repos:
  file.symlink:
    - target: /vagrant/workbench-repos
    - makedirs: True

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
    - target: /srv/workbench-repos/formulas/{{ slug }}
    - unless: test -d /srv/workbench-repos/formulas/{{ slug }}/.git
    - user: vagrant
    - identity: /home/vagrant/.ssh/id_rsa
{% if r.upstream is defined %}
  cmd.run:
    - name: git remote add upstream {{ r.upstream }}
    - unless: grep -q -e 'remote "upstream' .git/config
    - cwd: /srv/workbench-repos/formulas/{{ slug }}
    - user: vagrant

Add {{ slug }} entry in Workbench /etc/salt/master.d/roots.conf file_roots:
  cmd.run:
    - name: echo "    - /srv/workbench-repos/formulas/{{ slug }}" >> /etc/salt/master.d/roots.conf
    - unless: grep -q -e "formulas\/{{ slug }}" /etc/salt/master.d/roots.conf
{% endif %}

{% endfor %}
