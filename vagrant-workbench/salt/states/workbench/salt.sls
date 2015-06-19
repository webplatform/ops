Copy around the grains file for vagrant-minions to use:
  cmd.run:
    - name: cp /etc/salt/grains /vagrant/.grains
    - creates: /vagrant/.grains
    - onlyif: test -f /etc/salt/grains

