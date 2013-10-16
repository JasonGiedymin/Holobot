#!/bin/bash

sudo yum upgrade -y
# sudo yum install -y --nogpgcheck http://mirror.us.leaseweb.net/epel/6/i386/epel-release-6-8.noarch.rpm
sudo yum install -y --nogpgcheck http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm

# /etc/yum.repos.d/puppetlabs.repo
# add:
#   exclude=*mcollective*

sudo yum install -y puppet facter tar bind bind-utils

puppetModuleDir=/etc/puppet/modules
if [ ! -d $puppetModuleDir ]; then
  echo "Creating dir [$puppetModuleDir]..."
  sudo mkdir $puppetModuleDir
fi

sudo puppet module install openshift/openshift_origin

os_domain="localhost.localdomain"
sudo rm -f /var/named/K$os_domain.*
sudo /usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named $os_domain
temp_key=$(cat /var/named/K$os_domain.*.key  | awk '{print $8}')

printf "\n---dnssec key---\n$temp_key\n------\n\n"

cat<<EOF>/etc/sysconfig/network
NETWORKING=yes
HOSTNAME=broker.$os_domain
EOF
echo "broker.$os_domain" > /etc/hostname
hostname broker.$os_domain


# oo-register-dns --with-node-hostname broker --with-node-ip 192.168.3.19 --domain $os_name
