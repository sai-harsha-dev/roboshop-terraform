#!/bin/bash
labauto ansible
ansible-pull -U https://github.com/sai-harsha-dev/roboshop-ansible.git -e "role=catalogue" playbook.yml