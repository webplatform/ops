THIS_DIR:=$(shell pwd)

vagrant: .ssh/id_rsa
		vagrant up

.ssh/id_rsa:
		echo 'Make sure you put your own ssh key in ./ssh/. In the meantime we can generate one and you can send it to your source control tool'
		ssh-keygen -f ${THIS_DIR}/.ssh/id_rsa

empty:
		docker run -it --rm -p 8080:8080 ubuntu:14.04 bash

.PHONY: vagrant
