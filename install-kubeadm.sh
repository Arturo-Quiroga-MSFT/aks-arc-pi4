# script to deploy pre-requisites for kubeadm
# to install kubeadm
# to create a cluster with kubeadm

# Start with steps from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


sudo modprobe br_netfilter
lsmod | grep br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet


# continue with steps from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# first install a CNI, like CALICO ==> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

# Take care that your Pod network must not overlap with any of the host networks: you are likely to see problems if there is any overlap. 
# (If you find a collision between your network plugin's preferred Pod network and some of your host networks, you should think of a 
# suitable CIDR block to use instead, then use that during kubeadm init with --pod-network-cidr and as a replacement in your network plugin's 
# YAML).
#  Currently Calico is the only CNI plugin that the kubeadm project performs e2e tests against. 

# By default, kubeadm sets up your cluster to use and enforce use of RBAC (role based access control). 
# Make sure that your Pod network plugin supports RBAC, and so do any manifests that you use to deploy it.

