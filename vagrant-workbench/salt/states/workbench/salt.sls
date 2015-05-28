{% set formulas = salt['pillar.get']('workbench:gitfs_remotes').items() %}

{#
 # Clone git repositories and install them in specific location
 #
 # If you want to use a similar pattern, you might want to take a look
 # at salt-basesystem[1] in the macros folder.
 #
 # The following is a copy pasta so we don't need vagrant-workbench to require
 # salt-basesystem to install itself.
 #
 # [1]: https://github.com/webplatform/salt-basesystem
 #
 # NOTE: the code inside the following loop should be exactly the same as
 #       the salt-basesystem/macros/git.sls git_clone() macro.
 #}
{% for creates,args in formulas %}
{% set origin = args.origin %}

{# ========================= COPY-PASTA git_clone ========================= #}
{% set user = args.get('user', None) %}
{% set auth_key = args.get('auth_key', None) %}

{% set branchName = args.get('branch', 'master') %}
{% set remotes = args.get('remotes') %}

{% set before_unpack_remote = args.get('before', []) %}

Clone {{ creates }}:
  file.directory:
    - name: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{% if before_unpack_remote|count() >= 1 %}
    - watch_in:
{% for archive_dest in before_unpack_remote %}
      - file: Unpack {{ archive_dest }}
{% endfor %}
{% endif %}
  git.latest:
    - name: {{ origin }}
    - rev: {{ branchName }}
    - target: {{ creates }}
    - unless: test -d {{ creates }}/.git
{% if user %}
    - user: {{ user }}
{% endif %}
{% if auth_key %}
    - identity: {{ auth_key }}
{% endif %}
{% for remote_name,remote in remotes.items() %}
{% if remote_name != 'origin' %}
  cmd.run:
    - name: git remote add {{ remote_name }} {{ remote }}
    - unless: grep -q -e 'remote "{{ remote_name }}' .git/config
    - cwd: {{ creates }}
{% if user %}
    - user: {{ user }}
{% endif %}
{% endif %}
{% endfor %}
{# ========================= /COPY-PASTA git_clone ========================= #}

{% set slug = creates.split('/')|last() %}
Add {{ creates }} into Workbench /etc/salt/master.d/roots.conf:
  cmd.run:
    - name: echo "    - {{ creates }}" >> /etc/salt/master.d/roots.conf
    - unless: grep -q -e "formulas\/{{ slug }}" /etc/salt/master.d/roots.conf

{% endfor %}

