build dependencies:
  pkg.installed:
    - pkgs:
      - ruby-dev
      - gcc
      - dpkg-dev
      - autotools-dev
      - automake
      - libtool

fpm:
  gem.installed
