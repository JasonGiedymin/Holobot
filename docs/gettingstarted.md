Getting Started
---------------

## Building a new holobot base box
    cd scripts
    bundle install
    rake install:auto
    cd ../vagrant-boxes/holobot-dev
    vagrant up
    
    # to destroy
    # vagrant destroy --force
    
    # or to stop:
    # vagrant halt

    # replace vx with the version, i.e. v1.0
    vagrant package --output ../base-boxes/holobot-dev-vx.box


After following the above steps you should have a vagrant VM and a base box
which can be used as a vm for seeding additional holobot instances for dev.
