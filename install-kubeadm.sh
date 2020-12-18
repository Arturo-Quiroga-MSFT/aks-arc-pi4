# Script to deploy pre-requisites for kubeadm
# 1. to install kubeadm
# 2. to create a cluster with kubeadm

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
# first install a CNI, see overview ==> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

# Take care that your Pod network must not overlap with any of the host networks: you are likely to see problems if there is any overlap. 
# (If you find a collision between your network plugin's preferred Pod network and some of your host networks, you should think of a 
# suitable CIDR block to use instead, then use that during kubeadm init with --pod-network-cidr and as a replacement in your network plugin's 
# YAML).
#  Currently Calico is the only CNI plugin that the kubeadm project performs e2e tests against. 

# By default, kubeadm sets up your cluster to use and enforce use of RBAC (role based access control). 
# Make sure that your Pod network plugin supports RBAC, and so do any manifests that you use to deploy it.

# You can see all other CNIs in ==> https://kubernetes.io/docs/concepts/cluster-administration/networking/#calico
# If you choose CALICO, then follow these instructions ==> https://docs.projectcalico.org/getting-started/kubernetes/quickstart

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

watch kubectl get pods -n calico-system

# Optional step to allow scheduling of PODs in the master node
kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl get nodes -o wide

# Kubernetes networking basics
# The Kubernetes network model defines a “flat” network in which:
# - Every pod get its own IP address.
# - Pods on any node can communicate with all pods on all other nodes without NAT.
# - This creates a clean, backwards-compatible model where pods can be treated much like VMs or physical hosts from the perspectives of port allocation, 
#   naming, service discovery, load balancing, application configuration, and migration. Network segmentation can be defined using network policies 
#   to restrict traffic within these base networking capabilities.

# Within this model there’s quite a lot of flexibility for supporting different networking approaches and environments. 
# The details of exactly how the network is implemented depend on the combination of CNI, network, and cloud provider plugins being used.

