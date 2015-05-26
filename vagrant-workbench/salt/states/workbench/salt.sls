{% set formulas = salt['pillar.get']('workbench:gitfs_remotes').items() %}

{% for slug,r in formulas %}
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
{% set branchName = r.branch|default('master') %}
Clone {{ slug }} at {{ branchName }} into /srv/formulas:
  git.latest:
    - name: {{ r.origin }}
    - rev: {{ branchName }}
    - target: /srv/formulas/{{ slug }}
    - unless: test -d /srv/formulas/{{ slug }}/.git
    - user: vagrant
    - identity: /home/vagrant/.ssh/id_rsa
{% if r.upstream is defined %}
  cmd.run:
    - name: git remote add upstream {{ r.upstream }}
    - unless: grep -q -e 'remote "upstream' .git/config
    - cwd: /srv/formulas/{{ slug }}
    - user: vagrant

Add {{ slug }} entry in Workbench /etc/salt/master.d/roots.conf file_roots:
  cmd.run:
    - name: echo "    - /srv/formulas/{{ slug }}" >> /etc/salt/master.d/roots.conf
    - unless: grep -q -e "formulas\/{{ slug }}" /etc/salt/master.d/roots.conf
{% endif %}

{% endfor %}
