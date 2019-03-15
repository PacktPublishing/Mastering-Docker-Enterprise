# Docker Engine Install 

## Stash links need here

Sample Storebits Docker EE URL - https://storebits.docker.com/ee/ubuntu/sub-xxxxxxxxxx-xxxx-xxxxx-xxxxx-xxxxxxxxxxxx 

Docker Engine Install Docs - https://docs.docker.com/ee/supported-platforms/

## Ubuntu Docker Engine Install

This page walks through the process described here
https://docs.docker.com/install/linux/docker-ee/ubuntu/

On each linux node, update the package manager as follows.

```bash
sudo apt-get update
```

Now Enable APT to run over HTTPS using the command below.

```bash
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

Set up DOCKER_EE_URL environment variables using your Docker Store's Storebits URL that you recorded earlier. Then choose the Desired Docker version. You can find them listed using your (replacing x's) Storebits URL wuth this pattern:  <https://storebits.docker.com/ee/ubuntu/sub-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/dists/xenial/.> Your commands should look like the following.

```bash
DOCKER_EE_URL="https://storebits.docker.com/ee/ubuntu/sub-xxxxxxxxxx-xxxx-xxxxx-xxxxx-xxxxxxxxxxx"
DOCKER_EE_VERSION=stable-18.09
```

Below, we add Docker's repo to your linux package manager, update APT and then install the Docker EE version. 

```bash
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] $DOCKER_EE_URL/ubuntu \
   $(lsb_release -cs) \
   stable-18.09"

sudo apt-get update

sudo apt-get install -y docker-ee
```

Finally we add your current user to the Docker group to avoid running docker commands using Root or Sudo. 

```bash
sudo usermod -aG docker $USER
```

### Test the install

Log out. Then, log back in and try running docker command (without sudo)

```bash
docker info
```

## Windows 2016 Docker Engine Install

Add Docker Provide and Install Docker

```Powershell
Install-Module DockerMsftProvider -Force
Install-Package Docker -ProviderName DockerMsftProvider -Force
```

Check if restart and restart if necessary

```Powershell
(Install-WindowsFeature Containers).RestartNeeded
Restart-Computer
```

# Install UCP

SSH into your UCP/Manager node, install the Docker Universal Control Plane. As you might expect, the UCP installer runs from inside a container called docker/ucp:3.0.6. Notice how the container mounts the Docker socket as a volume so it can issues docker commands to Docker running on the host from inside the container. This is the preferred approach over DinD (Docker in Docker).  

```bash
docker container run -it --rm --name ucp \
-v /var/run/docker.sock:/var/run/docker.sock \
docker/ucp:3.1.2 install \
--host-address {internal IP Address of UCP Node}  \
--admin-username admin \
--admin-password {add your password here} \
--san {optional - internal IP of UCP node }  \
--san {optional - external DNS name UCP node } \
--san {optional - external IP of UCP node } \
--interactive
```

Once the install completes successfully, it time to log in. 

## Log Into the UCP Web Interface

Make sure that port 443 access is open between your browser and the UCP node. Then, point your browser to the external IP of your UCP node - MAKE sure to start with *https://*. PLEASE NOTE, by default and for the purposes of our PoC, the https session uses a self-signed certificate. To access UCP you will need to bypass the browser privacy warning and accept self-signed certificate. Use the username/password from your install command above. 

## Install Your Trial License

Using the Docker EE Trail license file you downloaded from the Docker Store when logging in. 

## Join Linux and Windows worker node

<https://docs.docker.com/ee/ucp/admin/configure/join-nodes/join-windows-nodes-to-cluster/#add-a-label-to-the-node>

Update/add file: C:\ProgramData\docker\config\daemon.json

```json
{
  "labels": ["os=windows"]
}
```

Restart Docker to pick up the label change

```Powershell
Restart-Service docker
```

# Install DTR

```bash
docker run -it --rm docker/dtr:2.6.2 install --ucp-url <ucp host>:443 --ucp-username admin --ucp-password <ucp password> --ucp-insecure-tls --ucp-node <name node where DTR is to be installed> 
```

## Trust DTR Nodes 

```bash
sudo curl -k https://dtr.mydomain.com/ca -o /etc/pki/ca-trust/source/anchors/dtr.mydomain.com.crt
sudo update-ca-trust
sudo /bin/systemctl restart docker.service
```

## Test Deploy Application as Services to the Swarm

Windows application from UCP manager:

```bash
docker service create -p 8000:80 --name aspnetcore_sample microsoft/dotnet-samples:aspnetapp
```

Linux Application:

```bash
docker service create --publish 80:80 nginx
```

# Docker Install Links

*Docker EE Certified Platforms*
<https://store.docker.com/search?type=edition&offering=enterprise>

*Docker EE Install Docs*
<https://docs.docker.com/ee/supported-platforms/>
