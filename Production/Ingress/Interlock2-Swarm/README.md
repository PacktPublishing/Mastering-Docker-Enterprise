# Setting Up Interlock2

### This is a sample exercise, not a recommondation of Interlock 2 for production systems.

Before you start, make sure you enable UCP's Layer 7 routing (Interlock2)

* Log into the UCP Web UI (as a UCP Administrator user)
* Navigate to admin > Admin Settings > Layer 7 Routing page

## Update Interlock service and pin proxy to dedicated node(s)

### Connect to the cluster using your UCP (admin) client bundle

```bash
# from the directory where your UCP admin client bundle was unzipped
source env.sh
```

Output from sourcing the admin bundle with env.sh

```console
Cluster "ucp_ucp.mydomain.com:6443_admin" set.
User "ucp_ucp.mydomain.com:6443_admin" set.
Context "ucp_ucp.mydomain.com:6443_admin" modified.
```

## Update the Interlock2 Configuration

Pull the current Interlock Config from UCP Manager and store it in a file called config.toml...

```bash
CURRENT_INTERLOCK_CONFIG_NAME=$(docker service inspect --format '{{ (index .Spec.TaskTemplate.ContainerSpec.Configs 0).ConfigName }}' ucp-interlock)

docker config inspect --format '{{ printf "%s" .Spec.Data }}' $CURRENT_INTERLOCK_CONFIG_NAME > config.toml
```

Edit the config.toml

* Update the ProxyConstraints property...

```toml
ProxyConstraints = ["node.labels.com.docker.ucp.orchestrator.swarm==true", "node.platform.os==linux", "node.labels.nodetype==interlocklb"]

```
* Update the PublishMode property...

```toml
PublishMode = "host"
```

Stuff the update config.toml into the UCP manager's config store, following interlock's config naming scheme and append it with the next numerical sequence number

```bash
NEW_INTERLOCK_CONFIG_NAME="com.docker.ucp.interlock.conf-$(( $(cut -d '-' -f 2 <<< "$CURRENT_INTERLOCK_CONFIG_NAME") + 1 ))"

docker config create $NEW_INTERLOCK_CONFIG_NAME config.toml
```

Update Interlock's Swarm service to use your new configuration

#### Remember you need to allow UCP admins to deploy workloads on the UCP managers

```bash
docker service update \
  --config-rm $CURRENT_INTERLOCK_CONFIG_NAME \
  --config-add source=$NEW_INTERLOCK_CONFIG_NAME,target=/config.toml \
  --publish-add mode=host,target=8080 \
  ucp-interlock
```

## Pin the Interlock2 proxy to a cluster node in Host Mode

We want the proxy to be on predetermined node where we can point our load balancer for inbound L7 routing

```bash
# List your UCP cluster nodes
docker node ls

# Pick a node(s) to host your ucp proxy and attach a label
# ... update node-name-here in command below!
docker node update --label-add nodetype=interlocklb node-name-here

# Update the Interlock proxy service 
docker service update \
    --constraint-add node.labels.nodetype==interlocklb \
    --replicas 1 \
    ucp-interlock-proxy
```

```bash
docker service create \
  --name demo \
  --detach=false \
  --label com.docker.lb.hosts=demo.mydomain.com \
  --label com.docker.lb.port=8080 \
  --publish mode=host,target=8080 \
  --env METADATA="demo" \
  ehazlett/docker-demo


```