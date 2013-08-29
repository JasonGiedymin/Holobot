HoloBot
====

## Dependencies
1. NVM
  1. Install the lastest released version from nodejs.org
     Known to work with at least v0.10.xx.
1. RVM
  1. make sure to actually set Ruby to at least v1.9.3.
     Project is known to work with v2.0.0.

## HoloBot Parts
1. apps
1. docs
1. scripts - automated scripts
1. vagrant-boxes - vagrant boxes
  - base-boxes - all the base boxes which we base off or create
  - holobot-dev - Vagrant box spec via Vagrantfile

We use vagrant to spin up VMs which host Holobot, a distributed docker management
plane.

