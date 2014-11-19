#!/bin/sh

apt-get -y install curl sshpass 

# install salt
curl -o bootstrap.sh -L http://bootstrap.saltstack.org
sh bootstrap.sh -M -N git v2014.1.13

# install pip
apt-get -y install python-pip python-dev build-essential
pip install --upgrade pip
# apt-get install python-dev python-pip -y

pip install -e git+https://git-wip-us.apache.org/repos/asf/libcloud.git@trunk#egg=apache-libcloud
echo "apache-libcloud version:"
python -c "import libcloud ; print libcloud.__version__"

pip install pycrypto==2.6.1
salt --versions-report


## Salt master configurations
# ensure firewall ports are open for salt
ufw allow 4505
ufw allow 4506

# auto configure salt-master IP from localmachine IP
CURRENT_IP=$(ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

envsubst <<EOF > /etc/salt/cloud
providers:
  gce-config:

    project: "black-inf"
    service_account_email_address: "845929625302-f5dqut87aipunjgl2jhq5lgvjbv7c2ul@developer.gserviceaccount.com"
    service_account_private_key: "/root/.ssh/black-8ac9a2d12429.pem"
    provider: gce

    ssh_username: ubuntu
    ssh_keyfile: /root/.ssh/id_rsa
EOF


envsubst <<EOF > /etc/salt/cloud.profiles
gce-n1-standard-1:
  minion:
    master: $CURRENT_IP
  image: ubuntu-1204-precise-v20141031
  size: n1-standard-1
  location: us-central1-a
  network: default
  tags: '[ "http-server", "https-server", "minion", "salt"]'
  metadata: '{"sshKeys": "ubuntu: $(cat /root/.ssh/id_rsa.pub) "}'
  use_persistent_disk: False
  delete_boot_pd: True
  deploy: True
  make_master: False
  provider: gce-config

salt_minion:
  minion:
    master: salt
  image: debian-7-wheezy-v20131120
  size: n1-standard-1
  location: us-central2-a
  make_master: False
  deploy: True
  tags: '["minion", "salt"]'
  provider: gce-config
EOF


# place minion config
cp ~/inf/salt/minion /etc/salt/



# place master config
# cp ~/inf/salt/master /etc/salt/


#mkdir /etc/salt/cloud.providers.d


# # default location for salt state files
# mkdir /srv/salt/
# cp ~/inf/salt/*.sls /srv/salt/


#mkdir /etc/salt/
# place master config
#cp ~/inf/salt/master /etc/salt/


# # place rackspace profiles
# mkdir /etc/salt/cloud.profiles.d
# cp ~/inf/salt/cloud.profiles.d/gcloud.conf /etc/salt/cloud.profiles.d/



# ### Misc openmpi installs
# cd master_scripts
# salt \* network.ip_addrs >> ../raw_out
# MPI_HOSTS=$(cat raw_out | python salt_ip_parser.py)
# echo "$MPI_HOSTS" > /srv/salt/mpi_hosts
# cd ..


# ## Configuring SSH for master + minions
# mkdir /srv/salt/.ssh/  # corresponding minion dir

# # Configuring SSH for master + minions
# mkdir /srv/salt/etc/ && mkdir /srv/salt/etc/ssh/
# cp /etc/ssh/ssh_config /srv/salt/etc/ssh/ # corresponding minion conf

# # Copy the key to authorized key folder and change permissions to allow SSH logins:
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys

# cp ~/.ssh/id_rsa* /srv/salt/.ssh/ # copy keys for minions



