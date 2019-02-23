# Notes from my UCP on Centos Install
Here are the notes from my Docker EE bare metal install on Centos 7.5. I'm not a system admin, but you wind these helpful. 

Use with care and at your own risk!

## Configure External DNS

Set up entries for UCP, DTR and *.mydomain.com to external LB

## Configure Internal (Split) DNS 
ucp.mydomain.com to first UCP node
dtr.mydomain.com to first DTR node
ucp-controller.kube-system.svc.cluster.local to UCP
forwarder entry for *.mydomain.com each app
NAT for Kubectl 6443

## Prepare nodes

### Centos 7.5 Install Notes

- Lots of disk for /var not too much for /home
- Network 10.10.1.x - main
- Network 10.50.1.x - NFS Storage
- - Do no allow default routes for NFS Net Adapter 
- - Leave gateway on NFS adapter undefined
- Network host names and default search mdomain.com


### Install ntp on all nodes

```bash
$ sudo yum install ntp
$ sudo systemctl restart network
$ sudo systemctl restart docker
```

### Install firewall rules on all nodes - just a starting point... 

```bash
$ sudo firewall-cmd --permanent --add-port=22/tcp
$ sudo firewall-cmd --permanent --add-port=80/tcp
$ sudo firewall-cmd --permanent --add-port=179/tcp
$ sudo firewall-cmd --permanent --add-port=443/tcp
$ sudo firewall-cmd --permanent --add-port=4443/tcp
$ sudo firewall-cmd --permanent --add-port=8443/tcp
$ sudo firewall-cmd --permanent --add-port=2376/tcp
$ sudo firewall-cmd --permanent --add-port=2377/tcp
$ sudo firewall-cmd --permanent --add-port=4789/udp
$ sudo firewall-cmd --permanent --add-port=6443/tcp
$ sudo firewall-cmd --permanent --add-port=6444/tcp
$ sudo firewall-cmd --permanent --add-port=7946/tcp
$ sudo firewall-cmd --permanent --add-port=7946/udp
$ sudo firewall-cmd --permanent --add-port=10250/tcp
$ sudo firewall-cmd --permanent --add-port=12376/tcp
$ sudo firewall-cmd --permanent --add-port=12378/tcp
$ sudo firewall-cmd --permanent --add-port=12379/tcp
$ sudo firewall-cmd --permanent --add-port=12380/tcp
$ sudo firewall-cmd --permanent --add-port=12381/tcp
$ sudo firewall-cmd --permanent --add-port=12382/tcp
$ sudo firewall-cmd --permanent --add-port=12383/tcp
$ sudo firewall-cmd --permanent --add-port=12384/tcp
$ sudo firewall-cmd --permanent --add-port=12385/tcp
$ sudo firewall-cmd --permanent --add-port=12386/tcp
$ sudo firewall-cmd --permanent --add-port=12387/tcp
$ sudo firewall-cmd --permanent --add-port=12388/tcp
$ sudo firewall-cmd --permanent --add-service=nfs
$ sudo firewall-cmd --permanent --add-service=ntp
$ sudo firewall-cmd --reload
```

#### (Handy Firewall commands)

```bash
$ sudo systemctl stop firewalld
$ sudo systemctl enable firewalld
$ sudo systemctl start firewalld
```


## Install Docker EE Engine for Centos 7.5

Get Docker (trial) License from store.docker.com. Record the storebits link
https://storebits.docker.com/ee/m/sub-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx

### Clean up any old Frankendocker

```bash
$ sudo yum remove docker \
$ docker-client \
$ docker-client-latest \
$ docker-common \
$ docker-latest \
$ docker-latest-logrotate \
$ docker-logrotate \
$ docker-selinux \
$ docker-engine-selinux \
$ docker-engine \
$ docker-ce

sudo rm /etc/yum.repos.d/docker*.repo
```

### Set up Centos Repos to REAL Docker and install

```bash
$ export DOCKERURL="https://storebits.docker.com/ee/m/sub-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
$ sudo -E sh -c 'echo "$DOCKERURL/centos" > /etc/yum/vars/dockerurl'
$ sudo yum install -y yum-utils
$ sudo -E yum-config-manager --add-repo "$DOCKERURL/centos/docker-ee.repo"
$ sudo yum-config-manager --enable docker-ee-stable-18.09
$ sudo yum -y install docker-ee
$ sudo systemctl start docker
$ sudo usermod -aG docker $USER
$ sudo systemctl enable docker
```

### Check the install!

```bash
$docker info
```
Sometimes there are warmings about ipv4 and ipv6 routing. If so use these to fix.

```bash
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl net.ipv4.ip_forward=1
```

### Init Swarm on UCP Manager node

Notice the my address pool configuration for Swarm overlay networks.

```bash
docker swarm init --advertise-addr 10.10.1.37 --default-addr-pool 10.60.0.0/16 --default-addr-pool-mask-length 26
```

Join Nodes as workers or managers 


### Optional, install 3rd party certs

Create volume for 3rd ucp-controller-server-certs and copy the ca.pem, cert.pem, and key.pem files to the root directory.

From your 3rd party cert create ca.pem, cert.pem and key.pem

```bash
docker volume create ucp-controller-server-certs
sudo -s
cp ./ca.pem /var/lib/docker/volumes/ucp-controller-server-certs/_data/
cp ./cert.pem /var/lib/docker/volumes/ucp-controller-server-certs/_data/
cp ./key.pem /var/lib/docker/volumes/ucp-controller-server-certs/_data/
exit
```

### Install UCP

#### Make sure you update variables for host address and UCP version
If there are error... Sometimes it installed fine, but took too long for the script.  If you have issues make sure your hardware meets the requirements.

```bash
$ docker image pull docker/ucp:3.1.1
$ docker container run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:3.1.1 install \
  --host-address 10.10.1.37 \
  --external-server-cert \
  --external-service-lb ucp.mydoamin.com \
  --license "$(cat license.lic)" \
  --interactive
```

### Install DTR from UCP Manager or UCP Admin client bundle

Make sure to use your parameters for URLs!
Also, please note I used a wildcard cert - same one for UCP and DTR


```bash
$ docker run -it --rm docker/dtr:2.6.0 install \
--dtr-external-url dtr.mydoamin.com \
--ucp-node ntc-dtr-1.mydoamin.com  \
--ucp-username admin  \
--ucp-url https://ucp.mydoamin.com  \
--replica-http-port 81 \
--replica-https-port 4443 \
--nfs-storage-url nfs://ntc-nfs-server.mydoamin.com/var/nfsshare/dtr \
--ucp-ca "$(cat wildcard.ca)" \
--dtr-ca "$(cat wildcard.ca)" \
--dtr-cert "$(cat wildcard.cert)" \
--dtr-key "$(cat wildcard.key)"

# Do not enable DTR image scanning through the DTR Web UI until all nodes are installed!

# Add DTR Replica for DTR 2
docker run -it --rm docker/dtr:2.6.0 join \
--ucp-node ntc-dtr-2.mydoamin.com  \
--ucp-username admin  \
--ucp-url https://ucp.mydoamin.com  \
--replica-http-port 81 \
--replica-https-port 4443 \
--ucp-ca "$(cat wildcard.ca)"

# Add DTR Replica for DTR 3
docker run -it --rm docker/dtr join \
--ucp-node ntc-dtr-3.mydoamin.com  \
--ucp-username admin  \
--ucp-url https://ucp.mydoamin.com  \
--replica-http-port 81 \
--replica-https-port 4443 \
--ucp-ca "$(cat wildcard.ca)"
```

## In case you need to reconfigure DTR, because you updated your UCP certs and now you are locked out of DTR single sign-on, use the DTR reconfigure command.

```bash
# IF DTR Reconfiguration is required...
docker run -it --rm docker/dtr reconfigure \
--dtr-external-url dtr.nvisia.io \
--ucp-username admin  \
--ucp-password ntc4U2day \
--ucp-url https://ucp.mydomain.com \
--replica-http-port 81 \
--replica-https-port 4443 \
--nfs-storage-url nfs://ntc-nfs-server.mydomain.com/var/nfsshare/dtr \
--ucp-ca "$(cat wildcard.ca)" \
--dtr-ca "$(cat wildcard.ca)" \
--dtr-cert "$(cat wildcard.cert)" \
--dtr-key "$(cat wildcard.key)"
```

## Have fun!