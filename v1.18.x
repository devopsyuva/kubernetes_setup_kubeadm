v1.18.x
=======

System requirements:

Ubuntu: 18.04 LTS server
Docker: 19.03.8 CE
CPU: 2
RAM: Min 4GB

Note: Disable swap memeory, if enabled.
++
root@kubernetesmanager:~# free -h
              total        used        free      shared  buff/cache   available
Mem:           3.9G        806M        2.5G        1.6M        567M        2.9G
Swap:            0B          0B          0B
root@kubernetesmanager:~# 
++


On both nodes (one controller and one compute node in below example):

Pre-request:

Install docker on all the nodes which you want to use for kubernetes cluster:

sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt update && apt-get install docker-ce docker-ce-cli containerd.io

Now, lets follow below steps to install kubernetes packages on all nodes:

sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

On order to instal specific version of packages, execute below command:

apt-get install -y kubelet=1.18.1-00 kubeadm=1.18.1-00 kubectl=1.18.1-00

apt-mark hold kubelet kubeadm kubectl

Follow below steps on manager nodes:

Note: I am exectuing all commands from root user, in your case use sudo for commands if user is having sudo previliges.

CNI --> Calico

we can customize the POD cidr to be set while installing if it is conflicts with base network.

For example, my base machines use 192.168.1.0/24. So I have customized calico to use 10.244.0.0/16 CIDR by downloading the calico.yaml file as below:

wget https://docs.projectcalico.org/v3.14/manifests/calico.yaml
vi calico.yaml --> search for below parameter:

- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"

save and exit


Now execute below commmand to bootstrap manager node:

++
root@kubernetesmanager:~# kubeadm init --apiserver-advertise-address=192.168.1.50 --pod-network-cidr=10.244.0.0/16
W0602 09:18:43.250517    3209 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.3
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubernetesmanager kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.50]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubernetesmanager localhost] and IPs [192.168.1.50 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubernetesmanager localhost] and IPs [192.168.1.50 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0602 09:29:13.501805    3209 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0602 09:29:13.505230    3209 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 30.008784 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node kubernetesmanager as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node kubernetesmanager as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: plndk5.qwxtyows7q4sz6ph
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.50:6443 --token plndk5.qwxtyows7q4sz6ph \
    --discovery-token-ca-cert-hash sha256:1fce13caf783e153b32cdcfcfef7e496e9bd192396609af19cb602382b1a5616 
root@kubernetesmanager:~# mkdir -p $HOME/.kube
root@kubernetesmanager:~#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
root@kubernetesmanager:~#   sudo chown $(id -u):$(id -g) $HOME/.kube/config
root@kubernetesmanager:~# 
root@kubernetesmanager:~# ls -l
total 24
-rw-r--r-- 1 root root 20846 Jun  2 09:17 calico.yaml
root@kubernetesmanager:~# vi calico.yaml 
root@kubernetesmanager:~# kubectl apply -f calico.yaml 
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
daemonset.apps/calico-node created
serviceaccount/calico-node created
deployment.apps/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
root@kubernetesmanager:~# 
++

Execute below commands on compute nodes to join to manager (check command from kubeadm init output):

root@workernodeone:~# kubeadm join 192.168.1.50:6443 --token plndk5.qwxtyows7q4sz6ph \
    --discovery-token-ca-cert-hash sha256:1fce13caf783e153b32cdcfcfef7e496e9bd192396609af19cb602382b1a5616
W0602 09:33:19.237245    5565 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

With this step we have done kubernetes setup, lets verify the nodes intigrated to kubernetes cluster:

execute below command on manager nodes

root@kubernetesmanager:~# kubectl get pods -n kube-system -o wide
NAME                                        READY   STATUS              RESTARTS   AGE     IP             NODE                NOMINATED NODE   READINESS GATES
calico-kube-controllers-75d56dfc47-d7xks    1/1     Running             0          9m31s   10.244.52.2    kubernetesmanager   <none>           <none>
calico-node-9dz2f                           1/1     Running             0          9m32s   192.168.1.50   kubernetesmanager   <none>           <none>
calico-node-gx6vx                           0/1     Init:2/3            0          7m14s   192.168.1.51   workernodeone       <none>           <none>
coredns-66bff467f8-f9v9m                    1/1     Running             0          10m     10.244.52.1    kubernetesmanager   <none>           <none>
coredns-66bff467f8-gqczx                    1/1     Running             0          10m     10.244.52.3    kubernetesmanager   <none>           <none>
etcd-kubernetesmanager                      1/1     Running             0          10m     192.168.1.50   kubernetesmanager   <none>           <none>
kube-apiserver-kubernetesmanager            1/1     Running             0          10m     192.168.1.50   kubernetesmanager   <none>           <none>
kube-controller-manager-kubernetesmanager   1/1     Running             1          10m     192.168.1.50   kubernetesmanager   <none>           <none>
kube-proxy-4xrrg                            0/1     ContainerCreating   0          7m14s   192.168.1.51   workernodeone       <none>           <none>
kube-proxy-z7v9p                            1/1     Running             0          10m     192.168.1.50   kubernetesmanager   <none>           <none>
kube-scheduler-kubernetesmanager            1/1     Running             0          10m     192.168.1.50   kubernetesmanager   <none>           <none>
root@kubernetesmanager:~# kubectl get nodes
NAME                STATUS   ROLES    AGE     VERSION
kubernetesmanager   Ready    master   11m     v1.18.1
workernodeone       Ready    <none>   7m29s   v1.18.1
root@kubernetesmanager:~# kubectl get pods -n kube-system -o wide
NAME                                        READY   STATUS    RESTARTS   AGE   IP             NODE                NOMINATED NODE   READINESS GATES
calico-kube-controllers-75d56dfc47-d7xks    1/1     Running   0          13m   10.244.52.2    kubernetesmanager   <none>           <none>
calico-node-9dz2f                           1/1     Running   0          13m   192.168.1.50   kubernetesmanager   <none>           <none>
calico-node-gx6vx                           1/1     Running   0          10m   192.168.1.51   workernodeone       <none>           <none>
coredns-66bff467f8-f9v9m                    1/1     Running   0          14m   10.244.52.1    kubernetesmanager   <none>           <none>
coredns-66bff467f8-gqczx                    1/1     Running   0          14m   10.244.52.3    kubernetesmanager   <none>           <none>
etcd-kubernetesmanager                      1/1     Running   0          14m   192.168.1.50   kubernetesmanager   <none>           <none>
kube-apiserver-kubernetesmanager            1/1     Running   0          14m   192.168.1.50   kubernetesmanager   <none>           <none>
kube-controller-manager-kubernetesmanager   1/1     Running   1          14m   192.168.1.50   kubernetesmanager   <none>           <none>
kube-proxy-4xrrg                            1/1     Running   0          10m   192.168.1.51   workernodeone       <none>           <none>
kube-proxy-z7v9p                            1/1     Running   0          14m   192.168.1.50   kubernetesmanager   <none>           <none>
kube-scheduler-kubernetesmanager            1/1     Running   0          14m   192.168.1.50   kubernetesmanager   <none>           <none>
root@kubernetesmanager:~# kubectl get nodes
NAME                STATUS   ROLES    AGE   VERSION
kubernetesmanager   Ready    master   14m   v1.18.1
workernodeone       Ready    <none>   11m   v1.18.1
root@kubernetesmanager:~#
