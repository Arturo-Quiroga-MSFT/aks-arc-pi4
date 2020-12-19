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

sudo apt-get update -y
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

# PRIOR TO RUNNING kubeadm!!!
# Append the cgroups and swap options to the kernel command line
# Note the space before "cgroup_enable=cpuset", to add a space after the last existing item on the line
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt

# pre-pull images needed by kubeadm init (if you want to install the latest version)
kubeadm config images pull

# at the master node do this, to do a dry run first
sudo kubeadm init --dry-run --kubernetes-version=v1.19 --pod-network-cidr=192.168.0.0/16

# if everything is ok, then do it for real
sudo kubeadm init --kubernetes-version=v1.19.1 --pod-network-cidr=192.168.0.0/16


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Kubernetes networking basics
# The Kubernetes network model defines a “flat” network in which:
# - Every pod get its own IP address.
# - Pods on any node can communicate with all pods on all other nodes without NAT.
# - This creates a clean, backwards-compatible model where pods can be treated much like VMs or physical hosts from the perspectives of port allocation, 
#   naming, service discovery, load balancing, application configuration, and migration. Network segmentation can be defined using network policies 
#   to restrict traffic within these base networking capabilities.

# Within this model there’s quite a lot of flexibility for supporting different networking approaches and environments. 
# The details of exactly how the network is implemented depend on the combination of CNI, network, and cloud provider plugins being used.

# At the masternode, install the chosen CNI (calico, in our case, other option would be flannel)
# from ==> https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-on-nodes
curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml

# The above step takes a while *** BE PATIENT***, and while things are deployed pods will go to error and some conatiners need time to be createdd

kubectl get pods --all-namespaces
kubectl get nodes -o wide

# Optional step to allow scheduling of PODs in the master node
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes -o wide

# At the worker nodes (after you install docker and all its requirements) install kubeadm, kubectl and kubelet.
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# At the worker nodes (after you install docker and kube programs) do a command like this, it is shown in the output from kubeadm init:
sudo kubeadm join 192.168.2.98:6443 --token wm2i1z.n64ym9oh2mr8ibwl \
    --discovery-token-ca-cert-hash sha256:f1c2905d5cad536ecf36511d93a31c22a1057d61ee857fc9dfa767a3b88cac82 

# label the worker nodes (from the master node)
kubectl label node workernode-1 node-role.kubernetes.io/worker1:w1
kubectl label node workernode-2 node-role.kubernetes.io/worker2:w1
kubectl label node workernode-3 node-role.kubernetes.io/worker3:w1

kubectl get nodes -o wide

