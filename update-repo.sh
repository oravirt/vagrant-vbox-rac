git submodule update --init --recursive
git submodule foreach git pull origin master
cd extra-provision/ansible-oracle
git submodule foreach git pull origin master
cd ../..
