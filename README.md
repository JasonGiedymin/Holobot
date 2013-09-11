HoloBot
=======

## Quickstart

The quickstart is divided into three parts.
1. install dependencies
1. cloning the repo
1. proceeding to the getting started section

### Dependencies

    # Install NVM aka (Node Version Manager)
    nvm use [the latest version]

    # Install RVM (Ruby Version Manager)
    # Install the latest 1.9.x or 2.0.x branch
    rvm use --default ruby-1.9.3-p327

    # If ever you get into gem dependency issues
    # go ahead and delete the ruby version entirely
    # and re-install
    rvm uninstall ruby-1.9.3-p327
    rvm install --default ruby-1.9.3-p327


### Execute the following

    git clone git@github.com:JasonGiedymin/Holobot.git
    git submodule update --init

    # Add the following line to the very top of the [./.git/config] file
    # It provides this simple command to delete submodules easily via: 
    #     git rms ./path/to/some/submodule
    [alias]
    rms = "!f(){ git rm --cached \"$1\";rm -r \"$1\";git config -f .gitmodules --remove-section \"submodule.$1\";git config -f .git/config --remove-section \"submodule.$1\";git add .gitmodules; }; f"


### Dependencies

Execute the following to install only dependencies

    rake install:deps

Execute the following to do a full install (which does the above implicitly)

    rake install:auto

Next see the wiki [Getting Started](https://github.com/JasonGiedymin/Holobot/wiki/gettingstarted)


## HoloBot Parts
1. apps
1. ~~docs~~ (replaced with wiki)
1. wiki - as a submodule, remember to do an init
1. scripts - automated scripts
1. vagrant-boxes - vagrant boxes
  - base-boxes - all the base boxes which we base off or create
  - holobot-dev - Vagrant box spec via Vagrantfile

We use vagrant to spin up VMs which host Holobot, a distributed docker management
plane built on CoreOS.

