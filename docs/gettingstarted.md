Getting Started
---------------

Before proceeding make sure you clone and handle any particular
requirements.

## Building a new holobot base box
    cd scripts
    bundle install
    rake install:auto
    cd ../vagrant-boxes/holobot-dev

    # to start a vagrant file
    vagrant up
    
    # to destroy
    # vagrant destroy --force
    
    # or to stop:
    vagrant halt

    # to suspend (pause)
    vagrant suspend

    # to resume (from a suspend)
    # note to restart from a halted machine do `vagrant up`
    vagrant resume

    # replace vx with the version, i.e. v1.0
    vagrant package --output ../base-boxes/holobot-dev-vx.box


After following the above steps you should have a vagrant VM and a base box
which can be used as a vm for seeding additional holobot instances for dev.

## Restart Twice

Currently CoreOS is not fully vagrant ready but there is enough that works.
Having said that you need to execute `vagrant up` twice.

You know when things are working when Holobot version says that it has started.

I.e.:
    linux-shell$ vagrant up
    [default] Running provisioner: shell...
    [default] Running: inline script
    Holobot-dev-v3 started...

