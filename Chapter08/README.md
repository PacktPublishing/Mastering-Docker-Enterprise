# Code snippets from Chapter 8

## Docker Bench

> <https://github.com/docker/docker-bench-security>

```bash
$ docker run -it --net host --pid host --userns host --cap-add
audit_control \
-e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
-v /var/lib:/var/lib \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib/systemd:/usr/lib/systemd \
-v /etc:/etc --label docker_bench_security \
docker/docker-bench-security
```

## UCP Config

### Use your UCP client bundle 
Change to the folder where you unzipped a UCP Admin's client bundle as you will need your UCP cert and key file.

```bash
# Use UCP cert and private key files
$ curl --cacert ca.pem --cert cert.pem --key key.pem
https://ucp.test.mydomain.com/api/ucp/configtoml

# List the contents of the ucp-config.toml file
$ cat ucp-config.toml
> ucp-config.toml
```

## NFS Set Up

```bash
## FOR EACH CLUSTER NODE ##
#*******************************************
#* NFS client Setup - just add nfs-utils *
#*******************************************
sudo yum install -y nfs-utils
```

### SSH to worker node A

#### Test NFS client with Docker Volume access

```bash
$ docker volume create --driver local \
--opt type=nfs \
--opt o=addr=test-iscsi-1.mydomain.com,rw \
--opt device=:/var/nfsshare/apps \
apps

# Create test-file.txt on NFS drive
docker run -it --rm -v apps:/apps centos:7 touch /apps/test-file.txt

# List file on apps volume from inside a cento:7 container
docker run -it --rm -v apps:/apps centos:7 ls /apps

# Clean up your volume
$ docker volume rm apps
```

### SSH to worker node B
> Remember to install nfs-utils on this node

> $ sudo yum install -y nfs-utils

```bash
$ sudo yum install -y nfs-utils
$ docker volume create --driver local \
--opt type=nfs \
--opt o=addr=test-iscsi-1.mydomain.com,rw \
--opt device=:/var/nfsshare/apps \
apps

# List file on apps volume from inside a cento:7 container
$ docker run -it --rm -v apps:/apps centos:7 ls /apps
$ docker volume rm apps
```

### Volume Snippet from Docker Stack file

```yaml
volumes:
    wiki-init-data:
        driver: local
        driver_opts:
            type: nfs
            o: addr=ntc-iscsi-1.mydomain.com,rw,hard
            device: ":/var/nfsshare/apps/wiki/db-init"
    wiki-db-data:
        driver: local
        driver_opts:
            type: nfs
            o: addr=ntc-iscsi-1.mydomain.com,rw,hard
            device: ":/var/nfsshare/apps/wiki/db-data"
```