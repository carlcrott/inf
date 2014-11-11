#!/bin/sh
## VERSION USED FOR RACKSPACE 
# utilizes the depreciated versions of salt-cloud
# based off of:
# http://www.onitato.com/deploying-to-rackspace-using-salt-cloud.html

## Installation of repo packages
# install salt prerequs 
# sudo apt-get -y install python-software-properties
# sudo add-apt-repository -y ppa:inf/salt
# sudo apt-get update

sudo apt-get -y install curl sshpass 

# install salt
curl -o bootstrap.sh -L http://bootstrap.saltstack.org
sh bootstrap.sh -M -N git v2014.1.0
######## so some combination of these two
# sudo add-apt-repository -y ppa:saltstack/salt
# sudo apt-get update

# echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu `lsb_release -sc` main | sudo tee /etc/apt/sources.list.d/saltstack.list
# wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | sudo apt-key add -
#####################




# #sudo apt-get -y install salt-master salt-minion salt-syndic

# install pip
apt-get -y install python-pip python-dev build-essential
pip -y install --upgrade pip

# finally salt

#sudo pip install salt-cloud
##TODO: clean up permissions
# should ubuntu have access to the installation dir for salt-cloud? /usr/local/lib/python2.7/dist-packages/saltcloud
# or maybe just install as sudo ... and ubuntu can run it w/o sudo ops

pip install apache-libcloud

# Edge apache-libcloud
#pip install -e git://github.com/apache/libcloud.git@trunk#egg=apache-libcloud

echo "apache-libcloud version:"
python -c "import libcloud ; print libcloud.__version__"


## Salt master configurations
# ensure firewall ports are open for salt
sudo ufw allow 4505 
sudo ufw allow 4506

# auto configure salt-master IP from localmachine IP
CURRENT_IP=$(ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

sudo mkdir /etc/salt
sudo chown -R ubuntu /etc/salt/
mkdir /etc/salt/cloud.providers.d


# generating file here to dynamically configure the salt master IP
# envsubst <<EOF > /etc/salt/cloud.providers.d/gcloud.conf
# gce-config:
#   # Set up the Project name and Service Account authorization
#   #
#   project: "calm-premise-758"
#   service_account_email_address: "601876700938-5hjvc9l9st7d5g2s0gqvq7f9ma93kfhr@developer.gserviceaccount.com"
#   service_account_private_key: "/home/ubuntu/.ssh/google_compute_engine"

#   # Set up the location of the salt master
#   #
#   minion:
#     master: saltmaster.example.com

#   # Set up grains information, which will be common for all nodes
#   # using this provider
#   grains:
#     node_type: broker
#     release: 1.0.1

#   provider: gce
# EOF


CURRENT_IP=$(ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')


envsubst <<EOF > /etc/salt/cloud
providers:
  gce-config:
    # Set the location of the salt-master
    #
    minion:
      master: $CURRENT_IP
    project: "calm-premise-758"
    service_account_email_address: "601876700938-5hjvc9l9st7d5g2s0gqvq7f9ma93kfhr@developer.gserviceaccount.com"
    service_account_private_key: "~/.ssh/infrastructure-edcab089aeb4.pem"
    provider: gce
EOF


cat > /etc/salt/cloud.profiles <<EOF
salt_minion:
  minion:
    master: salt
  image: ubuntu-1204-precise-v20141031
  size: n1-standard-1
  location: us-central1-a
  make_master: False
  deploy: True
  tags: '["minion", "salt"]'
  provider: gce-config

all_settings:
  image: ubuntu-1204-precise-v20141031
  size: n1-standard-1
  location: us-central1-a
  network: default
  tags: '["one", "two", "three"]'
  metadata: '{"one": "1", "2": "two"}'
  use_persistent_disk: True
  delete_boot_pd: False
  deploy: True
  make_master: False
  provider: gce-config
EOF



# place salts zeroMQ directory 
sudo chown -R ubuntu /srv
mkdir /srv/salt/

# configure permisssions for writing logs
sudo chown -R ubuntu /var/log/salt/
sudo chown ubuntu /var/log/salt/master

# # default location for salt state files
# cp ~/inf/salt/*.sls /srv/salt/

# # place master config
# cp ~/inf/salt/master /etc/salt/
# # place minion config
# cp ~/inf/salt/minion /srv/salt/
# # place minion scripts
# cp -r ~/inf/salt/minion_scripts/ /srv/salt/

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



