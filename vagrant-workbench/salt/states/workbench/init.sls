{% set salt_workbench_eth1 = salt['publish.publish']('salt', 'grains.get', 'ip4_interfaces:eth1') %}
{% set salt_master_ip = salt['pillar.get']('infra:hosts_entries:salt', '127.0.0.1') %}

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

Create unprivilegied DNS proxy server:
  pkg.installed:
    - name: dnsmasq

{% if grains['nodename'] != 'salt' %}
/etc/dnsmasq.d/workbench:
  file.managed:
    - contents: |
        # Managed by Salt Stack. Do NOT edit manually!
        server={{ salt_workbench_eth1[0]|default(salt_master_ip) }}#5353
{% endif %}

