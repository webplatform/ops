Copy around the grains file for vagrant-minions to use:
  cmd.run:
    - name: cp /etc/salt/grains /vagrant/.grains
    - creates: /vagrant/.grains
    - onlyif: test -f /etc/salt/grains

/etc/dnsmasq.d/workbench-salt:
  file.managed:
    - contents: |
        # Managed by Salt Stack. Do NOT edit manually!
        port=5353
    - require:
      - pkg: dnsmasq

