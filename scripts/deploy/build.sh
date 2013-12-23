#!/bin/bash
#
# build openshift rpms from source
#
if [[ $EUID -ne 0 ]]; then
   echo "You must run this script as root..." 1>&2
   exit 1
fi

yum upgrade -y
yum clean all

yum install -y git vim yum-plugin-priorities wget libxml2 \
libxml2-devel libxslt libxslt-devel ccache createrepo \
facter tar bind bind-utils

yum install -y ruby193 git vim ruby-augeas rubygem-rails rubygem-thor \
rubygem-parseconfig tito make rubygem-aws-sdk tig mlocate bash-completion \
rubygem-yard rubygem-redcarpet ruby-devel rubygems-devel redhat-lsb

gem install bundler

puppet module install puppetlabs/stdlib
puppet module install puppetlabs/ntp

# Needed if not using Fedora19:
#
# yum install -y --nogpgcheck http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
# yum install -y --nogpgcheck http://mirror.us.leaseweb.net/epel/6/i386/epel-release-6-8.noarch.rpm
#
# curl -L https://get.rvm.io | bash -s stable --ruby
# gem install thor aws aws-sdk nokogiri parseconfig yard redcarpet rdoc bundler
# gem install rdoc-data; rdoc-data --install
#

if [ -d origin-dev-tools ]; then
  rm -R origin-dev-tools
fi

git clone git://github.com/openshift/origin-dev-tools.git

# From origin-dev-tools's checkout
# export SKIP_SETUP=1
./origin-dev-tools/build/devenv clone_addtl_repos master

# From origin-dev-tools's checkout
# This step will install a lot of RPMs and will take a while
./origin-dev-tools/build/devenv install_required_packages

# From origin-dev-tools's checkout
./origin-dev-tools/build/devenv local-build

# From the origin-rpms directory
createrepo .