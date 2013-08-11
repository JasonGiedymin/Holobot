Ukko
====

#TODO


##R1 
Vagrant image of Ubuntu 13.x with the following (we will call this image `MasterBot`)
  - sudo apt-get update
  - sudo apt-get upgrade
  - sudo apt-get install -y ssh vim
  - get chef solo installed (must be solo, or puppet apply, or fabric)


##R2
Create `MasterBot-dev` image so it can 'create' `MasterBot` images. Dev image needs:
  - vagrant
  - vagrant-berkshelf
  - vagrant-omni
  - scala (latest release)
  - nvm (nodejs)
  - rvm
  - virtualenv
  - golang's binaries (does it have a nvm/rvm equivalent?)
  - java (1.7)


##R3

- `MasterBot-cpu`


##R4

- `CoreBot-cpu`

  
