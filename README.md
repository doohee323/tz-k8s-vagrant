# tz-k8s-vagrant

###################################################
## install 
###################################################

sudo apt install virtualbox -y
sudo apt install vagrant -y

sudo wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.deb
sudo dpkg –i vagrant_2.2.2_x86_64.deb
vagrant ––version
sudo mkdir ~/vagrant-ubuntu
cd ~/vagrant-ubuntu
sudo vagrant init ubuntu/trusty64
vagrant up

## master
vagrant ssh k8s-master

## node-1
vagrant ssh node-1

