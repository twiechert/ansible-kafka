ansible-kafka installation guide
---------

* These Ansible playbooks can build a Cloud environment and install Kafka with Zookeeper on it. Follow this [link](#install-kafka-on-rackspace-cloud).

* It can also install Kafka on existing Linux devices, be it dedicated devices in a datacenter or VMs running on a hypervizor. Follow this [link](#install-kafka-on-existing-devices).


---


# Install Kafka on Rackspace Cloud

## Build setup

First step is to setup the build node / workstation.

This build node or workstation will run the Ansible code and build the Kafka cluster (itself can be a Kafka node).

This node needs to be able to contact the cluster devices via SSH and the Rackspace APIs via HTTPS.

The following steps must be followed to install Ansible and the prerequisites on this build node / workstation, depending on its operating system:

### CentOS/RHEL 6

1. Install Ansible and git:

  ```
  sudo su -
  yum -y remove python-crypto
  yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum repolist; yum install gcc gcc-c++ python-pip python-devel sshpass git vim-enhanced -y
  pip install ansible pyrax importlib oslo.config==3.0.0
  ```

2. Generate SSH public/private key pair (press Enter for defaults):

  ```
  ssh-keygen -q -t rsa
  ```

### CentOS/RHEL 7

1. Install Ansible and git:

  ```
  sudo su -
  yum install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  yum repolist; yum install gcc gcc-c++ python-pip python-devel sshpass git vim-enhanced -y
  pip install ansible pyrax
  ```

2. Generate SSH public/private key pair (press Enter for defaults):

  ```
  ssh-keygen -q -t rsa
  ```

### Ubuntu 14+ / Debian 8

1. Install Ansible and git:

  ```
  sudo su -
  apt-get update; apt-get -y install python-pip python-dev sshpass git vim
  pip install ansible pyrax
  ```

2. Generate SSH public/private key pair (press Enter for defaults):

  ```
  ssh-keygen -q -t rsa
  ```

## Docker provisioning

  ```
    docker run -d -P --name kafka-01 ssh-ubuntu-16
    docker run -d -P --name kafka-02 ssh-ubuntu-16
    docker run -d -P --name kafka-03 ssh-ubuntu-16
  ```



## Kafka Installation

Run the following to proceed with the Zookeeper and Kafka installation.

Set the environment variable `RAX_CREDS_FILE` to point to the Rackspace credentials file(s) [set previously](#setup-the-rackspace-credentials-files).

```
export RAX_CREDS_FILE="/root/.raxpub"

cd ~/ansible-kafka/ && bash kafka_rax.sh
```


## Test

Run the following on a Zookeeper node (one of the first 3 nodes):

```
zkCli.sh -cmd ls /brokers/ids
zkCli.sh -cmd get /brokers/ids/1
```

It should return a list of all Kafka brokers and some information from the first broker.


---


# Install Kafka on existing devices


## Build setup

First step is to setup the build node / workstation.

This build node or workstation will run the Ansible code and build the Kafka cluster (itself can be a Kafka node).

This node needs to be able to contact the cluster devices via SSH.

All the SSH logins must be known / prepared in advance or alternative SSH public-key authentication can also be used.

The following steps must be followed to install Ansible and the prerequisites on this build node / workstation, depending on its operating system:

### CentOS/RHEL 6

Install Ansible and git:

```
sudo su -
yum install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum repolist; yum install python-pip python-devel sshpass git vim-enhanced -y
pip install ansible
```

### CentOS/RHEL 7

Install Ansible and git:

```
sudo su -
yum install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum repolist; yum install python-pip python-devel sshpass git vim-enhanced -y
pip install ansible
```

### Ubuntu 14+ / Debian 8

Install Ansible and git:

```
sudo su -
apt-get update; apt-get -y install python-pip python-dev sshpass git vim
pip install ansible
```


## Clone the repository

On the same build node / workstation, run the following:

```
cd; git clone https://github.com/rackerlabs/ansible-kafka
```


## Set the global variables

Modify the file at `~/ansible-kafka/playbooks/group_vars/all` to set the cluster configuration.

The following table will describe the most important variables:

| Variable           | Description                                                                                     |
| -------------------| ----------------------------------------------------------------------------------------------- |
| kafka_version      | The version of Kafka to install.                                                                |
| apache_mirror      | The mirror used to install Kafka and Zookeeper.                                                 |
| kafka_port         | The Kafka port (default is 9092).                                                               |
| cluster_interface  | Should be set to the network device that the Kafka nodes will listen on for client connections. |
| data_disks_devices | The device name of the data disk(s). If the disk is already partitioned / mounted or the root volume is to be used, set this variable to `[]`.  |


## Set the inventory

Modify the inventory file at `~/ansible-kafka/inventory/static` and add the nodes to install Kafka on.

- For each node, set the `ansible_host` to the IP address that is reachable from the build node / workstation.

- Then set `ansible_user=root` and `ansible_ssh_pass` if the node allows for root user logins. If these are not set, public-key authentication will be used.

- If root logins are not allowed then sudo can be used, set `ansible_user` to a user that can sudo.

- Example inventory with 3 nodes:

  ```
  [kafka-nodes]
  kafka-01 ansible_host=192.168.0.1 ansible_user=root ansible_ssh_pass=AsdQwe123
  kafka-02 ansible_host=192.168.0.2 ansible_user=root ansible_ssh_pass=AsdQwe123
  kafka-03 ansible_host=192.168.0.3 ansible_user=root ansible_ssh_pass=AsdQwe123
  ```


## Kafka Installation

Run the following to proceed with the Zookeeper and Kafka installation.

```
cd ~/ansible-kafka/ && bash kafka_static.sh
```


## Test

Run the following on a Zookeeper node (one of the first 3 nodes):

```
zkCli.sh -cmd ls /brokers/ids
zkCli.sh -cmd get /brokers/ids/1
```

It should return a list of all Kafka brokers and some information from the first broker.

