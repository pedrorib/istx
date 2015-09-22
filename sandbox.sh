#!/bin/sh
##


export OPENEDX_RELEASE=named-release/cypress
CONFIG_VER=$OPENEDX_RELEASE

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
	git clone https://github.com/edx/configuration
	cd configuration
	git checkout $CONFIG_VER
	
   if [ -n "$OPENEDX_RELEASE" ]; then
     EXTRA_VARS="-e edx_platform_version=$OPENEDX_RELEASE \
       -e certs_version=$OPENEDX_RELEASE \
       -e forum_version=$OPENEDX_RELEASE \
       -e xqueue_version=$OPENEDX_RELEASE \
     "
     CONFIG_VER=$OPENEDX_RELEASE
   else
     CONFIG_VER="named-release/cypress"
   fi

sed -i "/libblas/ s/^/#/g" /var/tmp/configuration/playbooks/roles/edxapp/tasks/python_sandbox_env.yml
sed -i "/liblapack/ s/^/#/g" /var/tmp/configuration/playbooks/roles/edxapp/tasks/python_sandbox_env.yml
sed -i "/liblapac/ s/^/#/g" /var/tmp/configuration/playbooks/roles/edxapp/tasks/python_sandbox_env.yml
sed -i "s/https/http/g" /var/tmp/configuration/playbooks/roles/elasticsearch/defaults/main.yml

fi

echo "3" >> ~/progress.txt

##
## Install the ansible requirements
##

if [["$(cat ~/progress.txt | tail --lines=1)"="3"]]; then
 echo "SKIPPING"
else
cd /var/tmp/configuration
sudo pip install -r requirements.txt
fi

##
## Run the edx_sandbox.yml playbook in the configuration/playbooks directory
##

cd /var/tmp/configuration/playbooks && sudo ansible-playbook -c local ./edx_sandbox.yml -i "localhost," $EXTRA_VARS
