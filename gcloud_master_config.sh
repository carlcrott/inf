#!/bin/sh
## VERSION USED FOR RACKSPACE 
# utilizes the depreciated versions of salt-cloud
# based off of:
# http://www.onitato.com/deploying-to-rackspace-using-salt-cloud.html

## Installation of repo packages
# install salt prerequs 
sudo apt-get -y install python-software-properties
sudo add-apt-repository -y ppa:saltstack/salt
sudo apt-get update

sudo apt-get -y install curl sshpass

# install salt
sudo apt-get -y install salt-master salt-minion salt-syndic

# install pip
sudo apt-get -y install python-pip python-dev build-essential
sudo pip -y install --upgrade pip

# finally salt
pip install salt-cloud
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
CURRENT_IP=$(ifconfig eth1 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

mkdir /etc/salt/cloud.providers.d

# generating file here to dynamically configure the salt master IP
envsubst <<EOF > /etc/salt/cloud.providers.d/gcloud.conf
providers:
  gce-config:
    # Set up the Project name and Service Account authorization
    #
    project: "infrastructure"
    service_account_email_address: "carlcrott@gmail.com"
    service_account_private_key: "/path/to/your/NEW.pem"

    # Set up the location of the salt master
    #
    minion:
      master: saltmaster.example.com

    # Set up grains information, which will be common for all nodes
    # using this provider
    grains:
      node_type: broker
      release: 1.0.1

    provider: gce
EOF


# place salts zeroMQ directory 
mkdir /srv/salt
# default location for salt state files
cp ~/saltstack/salt/*.sls /srv/salt/

# place master config
cp ~/saltstack/salt/master /etc/salt/
# place minion config
cp ~/saltstack/salt/minion /srv/salt/
# place minion scripts
cp -r ~/saltstack/salt/minion_scripts/ /srv/salt/

# place rackspace profiles
mkdir /etc/salt/cloud.profiles.d
cp ~/saltstack/salt/cloud.profiles.d/* /etc/salt/cloud.profiles.d/



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



