Installing Kubernetes cluster on Ubuntu:
========================================
Below are the detailed steps for installing kubernetes cluster on ubuntu.

Pre-Requisites:
==============
Need 2 VM's
1. Master :4gGB ram 2CPUs
2. Worker :2GB  ram 1CPU


Execute the following commands on both master and slave nodes:
==============================================================
1. sudo su 
```
#apt-get update
```
2. Turn of swap space
```
# swapoff -a
# nano /etc/fstab and comment the line which has swap information (Leave if already commented)
```
```
3.update the hostnames on both master and slave
#nano /etc/hostname
```
```
Make our machine ip static.Below id the process of making aan ip address static:
# nano /etc/network/interfaces
```

Now enter the below lines in the file:

```
auto enp0s8
iface enp0s8 inet static
address <IP-Address-Of-VM>
```

4. Add the ips of both master and worker in the /etc/hosts file
``# nano /etc/hosts
``

Do the above steps  on your worker node as well!!



*******After completion of above steps restart your machines*******

5. Install docker:
```
# sudo su
# apt-get update 
# apt-get install -y docker.io
```
6. Run the below commands before installing the Kubernetes components

```commandline
1. update packages and their version
# sudo apt-get update && sudo apt-get upgrade -y

2. install curl and apt-transport-https
# sudo apt-get update && sudo apt-get install -y apt-transport-https curl

3. add key to verify releases
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

4. add kubernetes apt repo
# cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```
***************Completed pre-installation steps***************

Kubernetes env installation:
============================
7.Install kubeadm, kubectl, and kubelet.
```
# sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
```
8.Next,run apt-mark hold  so that these packages will not be updated/removed automatically:
```
# sudo apt-mark hold kubelet kubeadm kubectl
```

After updating restart your matches for the lat time to reflect all the changes.

*********With this kubernetes on both machines  is installed successfully*********


On Master Node :
================
1. Run the below commands on the master node
```
Step 1:Start our Kubernetes cluster from the master’s machine:
# kubeadm init --apiserver-advertise-address=<ip-address-of-kmaster-vm> --pod-network-cidr=192.168.0.0/16

You will get some output which you need to execute using a normal user.

Install a pod network
$kubectl apply -f  https://docs.projectcalico.org/v3.14/manifests/calico.yaml

9.To verify, if kubectl is working or not, run the following command:
$ kubectl get pods -o wide --all-namespaces

For installing dashboard pod
$kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml 

Start dashboard
$kubectl proxy --starting the dashboard
```

2. View the dashboard on the master vm using the  url [kubernetes-dashboard-url](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login)
 
 
3. In this step, we will create the service account for the dashboard and get it’s credentials.
Note: Run all these commands in a new terminal, or your kubectl proxy command will stop. 
   
```
1. This command will create a service account for dashboard in the default namespace
$ kubectl create serviceaccount dashboard -n default

2. This command will add the cluster binding rules to your dashboard account
$ kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

3. This command will give you the token required for your dashboard login
$ kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
 
 use the generated token to sign in to the dashboard

 ```

 On worker:
=================================
```
To join the cluster run the below command:
$kubeadm join 192.168.218.144:6443 --token wlq1y5.qyl572qrk6phai2g \
>     --discovery-token-ca-cert-hash sha256:53dd60b36c440f334a151c480443c02626b86c39056a0ccf5250aa8990e45449
```

***************worker has joined master successfully***************


Check successful installation :
===============================
Run the kubectl commands to check for installation 
```
$kubectl get nodes
master@kubemaster:~$ kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
kubemaster   Ready    control-plane,master   46m   v1.20.1
kubeworker   Ready    control-plane,worker   23m   v1.20.1
```


To Uninstall kubernetes service:
================================
```
# sudo kubeadm reset
# sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*   
# sudo apt-get autoremove  
# sudo rm -rf ~/.kube
```

************************************END OF INSTLLATION************************************

Errors and solutions:
=====================
### ERR-1 :

```
root@kubeworker:/home/worker# kubectl cluster-info

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
### Solution:

```
mkdir ~/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### ERR-2
Some times the kubelet might not start with the below error:

```commandline
[kubelet-check] It seems like the kubelet isn't running or healthy.
[kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get http://localhost:10248/healthz: dial tcp 127.0.0.1:10248: connect: connection refused.


Unfortunately, an error has occurred:
            timed out waiting for the condition

This error is likely caused by:
            - The kubelet is not running
            - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)
            - No internet connection is available so the kubelet cannot pull or find the following control plane images:
                - k8s.gcr.io/kube-apiserver-amd64:v1.11.2
                - k8s.gcr.io/kube-controller-manager-amd64:v1.11.2
                - k8s.gcr.io/kube-scheduler-amd64:v1.11.2
                - k8s.gcr.io/etcd-amd64:3.2.18
                - You can check or miligate this in beforehand with "kubeadm config images pull" to make sure the images
                  are downloaded locally and cached.

        If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands:
            - 'systemctl status kubelet'
            - 'journalctl -xeu kubelet'

        Additionally, a control plane component may have crashed or exited when started by the container runtime.
        To troubleshoot, list all containers using your preferred container runtimes CLI, e.g. docker.
        Here is one example how you may list all Kubernetes containers running in docker:
            - 'docker ps -a | grep kube | grep -v pause'
            Once you have found the failing container, you can inspect its logs with:
            - 'docker logs CONTAINERID'
couldn't initialize a Kubernetes cluster
```

### Solution:
Chek the journalctl logs for the kubelet service you might find an issue with the cgroupdriver or because the swap space is on

#### sol-1-Turn of the swap space and restart kubeadm
```commandline
#sudo swapoff -a
#sudo sed -i '/ swap / s/^/#/' /etc/fstab
# kubeadm init
```

#### sol-2 
There are chances that the kubeadm init command is going to fail saying the different cgroup drvers are being used in the kubelet (systemd) and docker (cgroupfs) service. To resolve that we will make sure that both the services are running with the same cgroup driver. It's recommended that we use systemd as cgroup driver for both of the services. To restart docker with systemd as cgroup driver, change the service file (/lib/systemd/system/docker.service) for docker to accept cgroup driver

```commandline
# vi /lib/systemd/system/docker.service
# ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock ## append --exec-opt native.cgroupdriver=systemd at the end
# kubeadm reset
# kubeadm init
```