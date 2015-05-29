#!/bin/sh
##
## Installs the pre-requisites for running edX on a single Ubuntu 12.04
## instance.  This script is provided as a convenience and any of these
## steps could be executed manually.
##
## Note that this script requires that you have the ability to run
## commands as root via sudo.  Caveat Emptor!
##

##
## Sanity check
##
if [[ ! "$(lsb_release -d | cut -f2)" =~ $'Ubuntu 14.04.2 LTS' ]]; then
   echo "Esta versão da configuração foi modificada para trabalhar somente com Ubuntu 14.04.2 LTS. Abortar";
   exit;
else
echo "Esta é uma versão modificada para Ubuntu 14.04. Usar com cuidado."
fi

##
## Update and Upgrade apt packages
##
sudo apt-get update -y
sudo apt-get upgrade -y

echo "1" > ~/progress.txt 

##
## Install system pre-requisites
##
if [["$(cat ~/progress.txt | tail --lines=1)" = "1"]]; then
 echo "SKIPPING"
else
sudo apt-get install -y build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev python-pip python-apt python-dev
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenv
fi

echo "2" >> ~/progress.txt

##
## Clone the configuration repository and run Ansible
##
if [["$(cat ~/progress.txt | tail --lines=1)"="2"]]; then
 echo "SKIPPING"
else
cd /var/tmp
git clone https://github.com/pedrorib/istx.git
fi

echo "3" >> ~/progress.txt

##
## Install the ansible requirements
##

if [["$(cat ~/progress.txt | tail --lines=1)"="3"]]; then
 echo "SKIPPING"
else
cd /var/tmp/istx
sudo pip install -r requirements.txt
fi

echo "4" >> ~/progress.txt

##
## Run the edx_sandbox.yml playbook in the configuration/playbooks directory
##
if [["$(cat ~/progress.txt | tail -lines=1)"="4"]]; then
 echo "SKIPPING"
else
cd /var/tmp/istx/playbooks && sudo ansible-playbook -c local ./edx_sandbox.yml -i "localhost," $EXTRA_VARS
fi

rm ~/progress.txt
