# from ==> https://docs.docker.com/engine/install/ubuntu/

sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

# docker for ARM64
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "install docker ce"
sudo apt-get update -y 
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
echo "test if docker is working"
sudo docker run hello-world

echo "adding your user to the docker group"
sudo usermod -aG docker $USER

sudo systemctl enable docker

sudo docker info

echo "configure iptables"
# Enable net.bridge.bridge-nf-call-iptables and -iptables6
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
$ sudo sysctl --system

# Set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "setup the docker service to start at reboot"
# Create /etc/systemd/system/docker.service.d
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker



# PRIOR TO RUNNING kubeadm!!!
# Append the cgroups and swap options to the kernel command line
# Note the space before "cgroup_enable=cpuset", to add a space after the last existing item on the line
echo "Enabling Memory cgroup"
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt
echo "Check that everythings is OK prior to initializing the cluster"
sudo docker info
echo "Rebooting now for changes to take effect!!"
sudo reboot



