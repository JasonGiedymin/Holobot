#!/bin/bash
#
# build openshift rpms from source
#
if [[ $EUID -ne 0 ]]; then
   echo "You must run this script as root..." 1>&2
   exit 1
fi

yum install -y rubygem-thor git tito yum-plugin-priorities wget
yum install -y ruby-devel rubygems-devel rubygem-aws-sdk rubygem-parseconfig 
yum install -y rubygem-yard rubygem-redcarpet createrepo

if [ -d origin-dev-tools ]; then
  rm -R origin-dev-tools
fi

git clone git://github.com/openshift/origin-dev-tools.git

# From origin-dev-tools's checkout
export SKIP_SETUP=1
./origin-dev-tools/build/devenv clone_addtl_repos master

# From origin-dev-tools's checkout
# This step will install a lot of RPMs and will take a while
./origin-dev-tools/build/devenv install_required_packages

# From origin-dev-tools's checkout
./origin-dev-tools/build/devenv local-build --skip-install

# From the origin-rpms directory
createrepo .