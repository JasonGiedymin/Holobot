#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "You must run this script as root..." 1>&2
   exit 1
fi

yum install -y ntpdate ntp
ntpdate clock.redhat.com
systemctl enable ntpd.service
systemctl start  ntpd.service

#
# Yum Upgrade
#
yum clean all
sudo yum upgrade -y
# sudo yum install -y --nogpgcheck http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
# sudo yum install -y --nogpgcheck http://mirror.us.leaseweb.net/epel/6/i386/epel-release-6-8.noarch.rpm

git clone https://github.com/JasonGiedymin/openshift-extras.git
cd openshift-extras
git checkout --track origin/fix/puppet-apply
cd oo-install
bundle


#sh <(curl -s http://oo-install.rhcloud.com/)

# /etc/yum.repos.d/puppetlabs.repo
# add:
#   exclude=*mcollective*
sudo yum install -y puppet facter tar bind bind-utils

#
# Prep puppet
#
puppetModuleDir=/etc/puppet/modules
if [ ! -d $puppetModuleDir ]; then
  echo "Creating dir [$puppetModuleDir]..."
  sudo mkdir $puppetModuleDir
fi
sudo puppet module install openshift/openshift_origin


#
# Key Generation
#
domain="example.com"
keyfile=/var/named/${domain}.key
pushd /var/named
rm -f K${domain}*
dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom ${domain}
KEY="$(grep Key: K${domain}*.private | cut -d ' ' -f 2)"
popd

printf "\n---dnssec key---\n$KEY\n------\n\n"

rndc-confgen -a -r /dev/urandom
restorecon -v /etc/rndc.* /etc/named.*
chown -v root:named /etc/rndc.key
chmod -v 640 /etc/rndc.key

#
# Forwarders
#
echo "forwarders { 8.8.8.8; 8.8.4.4; } ;" >> /var/named/forwarders.conf
restorecon -v /var/named/forwarders.conf
chmod -v 640 /var/named/forwarders.conf

rm -rvf /var/named/dynamic
mkdir -vp /var/named/dynamic

#
# DNS Record
#
cat <<EOF > /var/named/dynamic/${domain}.db
\$ORIGIN .
\$TTL 1 ; 1 seconds (for testing only)
${domain}       IN SOA  ns1.${domain}. hostmaster.${domain}. (
            2011112904 ; serial
            60         ; refresh (1 minute)
            15         ; retry (15 seconds)
            1800       ; expire (30 minutes)
            10         ; minimum (10 seconds)
            )
        NS  ns1.${domain}.
        MX  10 mail.${domain}.
\$ORIGIN ${domain}.
ns1         A   127.0.0.1
EOF

cat /var/named/dynamic/${domain}.db


#
# DNSSEC Key
#
cat <<EOF > /var/named/${domain}.key
key ${domain} {
  algorithm HMAC-MD5;
  secret "${KEY}";
};
EOF

# correct perms
echo "==== correct perms ===="
chown -Rv named:named /var/named
restorecon -rv /var/named

#
# edit named.conf
#
sudo cat <<EOF > /etc/named.conf
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

options {
    listen-on port 53 { any; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { any; };
    recursion yes;

    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.iscdlv.key";

    // set forwarding to the next nearest server (from DHCP response
    forward only;
    include "forwarders.conf";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

// use the default rndc key
include "/etc/rndc.key";

controls {
    inet 127.0.0.1 port 953
    allow { 127.0.0.1; } keys { "rndc-key"; };
};

include "/etc/named.rfc1912.zones";

include "${domain}.key";

zone "${domain}" IN {
    type master;
    file "dynamic/${domain}.db";
    allow-update { key ${domain} ; } ;
};
EOF

# set perms
chown -v root:named /etc/named.conf
restorecon /etc/named.conf

# add to top of resolve.conf
echo 'nameserver 127.0.0.1' | cat - /etc/resolv.conf > temp && mv temp /etc/resolv.conf

#
# configure firewall
#
firewall-cmd --add-service=dns
firewall-cmd --permanent --add-service=dns
systemctl enable named.service


#
# restart named service
#
systemctl start named.service

#
# add broker node
#
nsupdate -k ${keyfile}

# test
ping broker.example.com

dig @127.0.0.1 broker.example.com