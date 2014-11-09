#!/bin/sh
## VERSION USED FOR RACKSPACE 
# utilizes the depreciated versions of salt-cloud
# based off of:
# http://www.onitato.com/deploying-to-rackspace-using-salt-cloud.html

## Installation of repo packages
# install salt prerequs 
sudo apt-get -y install python-software-properties
sudo add-apt-repository -y ppa:inf/salt
sudo apt-get update

sudo apt-get -y install curl sshpass 

# install salt

######## so some combination of these two
sudo add-apt-repository -y ppa:saltstack/salt
sudo apt-get update

echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu `lsb_release -sc` main | sudo tee /etc/apt/sources.list.d/saltstack.list
wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | sudo apt-key add -
#####################





sudo apt-get -y install salt-master salt-minion salt-syndic

# install pip
sudo apt-get -y install python-pip python-dev build-essential
sudo pip -y install --upgrade pip

# finally salt

sudo pip install salt-cloud
##TODO: clean up permissions
# should ubuntu have access to the installation dir for salt-cloud? /usr/local/lib/python2.7/dist-packages/saltcloud
# or maybe just install as sudo ... and ubuntu can run it w/o sudo ops

sudo pip install apache-libcloud

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
envsubst <<EOF > /etc/salt/cloud.providers.d/gcloud.conf
providers:
  gce-config:
    # Set up the Project name and Service Account authorization
    #
    project: "infrastructure"
    service_account_email_address: "carlcrott@gmail.com"
    service_account_private_key: "google_compute_engine.pub"

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
sudo chown -R ubuntu /srv
mkdir /srv/salt/

# default location for salt state files
cp ~/inf/salt/*.sls /srv/salt/

# place master config
cp ~/inf/salt/master /etc/salt/
# place minion config
cp ~/inf/salt/minion /srv/salt/
# place minion scripts
cp -r ~/inf/salt/minion_scripts/ /srv/salt/

# place rackspace profiles
mkdir /etc/salt/cloud.profiles.d
cp ~/inf/salt/cloud.profiles.d/* /etc/salt/cloud.profiles.d/



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



