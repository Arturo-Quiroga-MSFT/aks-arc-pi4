# Download UBUNTU ARM image from the following site
https://ubuntu.com/download/raspberry-pi/thank-you?version=20.04.1&architecture=server-arm64+raspi

# installation instructions are here: 
https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview

# (you may want to use BALENA ETCHER to prepare the SD CARD, it is easier)
https://www.balena.io/etcher/

# Determining the Pi’s IP address
# To determine the IP address of your board, open a terminal and run the arp command:
# On Ubuntu and Mac OS:
arp -na | grep -i "b8:27:eb"

# If this doesn’t work and you are using the latest Raspberry Pi 4, instead run:
arp -na | grep -i "dc:a6:32"

# On Windows:
arp -a | findstr b8-27-eb

# If this doesn’t work and you are using the latest Raspberry Pi 4, instead run:
arp -a | findstr dc-a6-32

# This will return an output similar to:
 ? (xx.xx.xx.x) at b8:27:eb:yy:yy:yy [ether] on wlp2s0

# or use ping:
ping ubuntu

# or find it via your router's gui

# login to ubuntu (original hostname is ubuntu, original username and password is ubuntu)
ssh ubuntu@<Raspberry Pi’s IP address>

# change hostname
hostnamectl set-hostname <new name>

# Update UBUNTU
sudo apt update -y
sudo apt upgrade -y

# 1. Install docker on all nodes ==> https://docs.docker.com/engine/install/ubuntu/
# see install-docker.sh

# 2. Proceed to bootstrap the cluster using kubeadm
# see install-kubeadm.sh
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

