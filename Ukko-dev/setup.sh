#! /bin/bash

# maintenance
sudo apt-get -y update
sudo apt-get -y upgrade

# headers
sudo apt-get install linux-headers-$(uname -r)

sudo apt-get install build-essential

# deps
sudo apt-get install vim git virtualbox vagrant

