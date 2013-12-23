HoloBot
=======

# NOTE

Here lies a dead project, but a wonderful learning experiment and discussion.

It was an experiment with Docker, coreos, and vagrant, taking automation to the extreme.

Through time, it morphed and many problems were surfaced. For example,
a common developement platform (solved by vagrant), slow platform, reliance on
alpha code (coreos, docker), vagrant/provider issues, and application deployment 
consistencies between development and production deployment.

Most of the work in this project was done in 15-20 min sessions as most of the
devs on this project work full time. Keep that in mind as you read the code,
and peruse the docs.

This project was a good discussion on the above topics, and it also lead us
to start on another which I may open source as well in the very near future.

That project also came with issues, but solved many of the ones we saw here.


## Quickstart

The quickstart is divided into three parts.

1. install dependencies
1. cloning the repo
1. proceeding to the getting started section

### Dependencies

    # VirtualBox
    # Install version 4.2.18
    # https://www.virtualbox.org/wiki/Downloads or
    # https://www.virtualbox.org/wiki/Download_Old_Builds_4_2
    # Note that you may encounter weird problems with guest additions
    # depending on what version of VirtualBox you use.

    # Vagrant
    # Install version v1.3.4
    # http://downloads.vagrantup.com/tags/v1.3.4

    # Install NVM aka (Node Version Manager) https://github.com/creationix/nvm
    NODEJS_LATEST=$(nvm ls-remote | tail -n1)
    nvm install $NODEJS_LATEST # installs the latest if not installed
    nvm use $NODEJS_LATEST

    # Install RVM (Ruby Version Manager)
    # Install the latest 1.9.x or 2.0.x branch
    HOLOBOT_RUBY=1.9.3-p448
    rvm install --default $HOLOBOT_RUBY
    # Use that ruby
    rvm use --default $HOLOBOT_RUBY

    # If ever you get into gem dependency issues
    # go ahead and delete the ruby version entirely
    # and re-install
    rvm uninstall $HOLOBOT_RUBY
    rvm install --default $HOLOBOT_RUBY

    gem install berkshelf bundler


### Execute the following

    git clone git@github.com:JasonGiedymin/Holobot.git
    git submodule update --init

    # The following git alias provides
    # a simple command to delete submodules easily via: 
    #     git rms ./path/to/some/submodule
    git config alias.rms "!f(){ git rm --cached \"$1\";rm -r \"$1\";git config -f .gitmodules --remove-section \"submodule.$1\";git config -f .git/config --remove-section \"submodule.$1\";git add .gitmodules; }; f"

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

We use vagrant to spin up VMs which host Holobot, a distributed docker management plane built on CoreOS.


## Hooks

1. Trello is tied to the repo for quick push/pull/merged list visability.

