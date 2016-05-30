#!/bin/bash

VARS="${VARS} ANSIBLE_SCP_IF_SSH=y ANSIBLE_HOST_KEY_CHECKING=False"
export $VARS

ansible-playbook -v -f 20 -i inventory/static playbooks/kafka.yml
