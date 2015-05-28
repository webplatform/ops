workbench:
  gitfs_remotes:
    /srv/formulas/basesystem:
      origin: git@github.com:webplatform/salt-basesystem.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/webplatform/salt-basesystem.git
    /srv/formulas/sysctl:
      origin: git@github.com:webplatform/saltstack-sysctl-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/bechtoldt/saltstack-sysctl-formula.git
    /srv/formulas/postgres:
      origin: git@github.com:webplatform/postgres-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/postgres-formula.git
    /srv/formulas/docker:
      origin: git@github.com:webplatform/docker-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/docker-formula.git
    /srv/formulas/logrotate:
      origin: git@github.com:webplatform/logrotate-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/logrotate-formula.git
    /srv/formulas/redis:
      origin: git@github.com:webplatform/redis-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/redis-formula.git
    /srv/formulas/nfs:
      origin: git@github.com:webplatform/nfs-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/nfs-formula.git
    /srv/formulas/logstash:
      origin: git@github.com:webplatform/logstash-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/saltstack-formulas/logstash-formula.git
    /srv/formulas/emailblackhole:
      origin: git@github.com:renoirb/emailblackhole-formula.git
      user: vagrant
      auth_key: /home/vagrant/.ssh/id_rsa
      remotes:
        upstream: https://github.com/renoirb/emailblackhole-formula.git
