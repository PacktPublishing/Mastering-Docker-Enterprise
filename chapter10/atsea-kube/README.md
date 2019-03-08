# Converting the Atsea appliation to Kubernetes

## Checklist

### Local build and test Docker Desktop

- Create namespace
- ConfigMap for DB nme and DB user
- Secrets for DB password
- DB pod deployments
- DB ClusterIP service
- Webapp pod deplyment
- Webapp NodePort service 

### Deploy to UCP

- atsea-test namespace in UPC
- Update NodePorts port for UCP ephemeral range
- Deploy 
- Smoke test
- Update LB

### Create a namespace for our deployment

```bash
$ kubectl apply -f create-app-namespace.yaml
namespace/atsea-test created
```

### Create configmap.yaml and apply it.

```bash
$ kubectl apply -f configmap.yaml
configmap/dbconfig created

$ kubectl -n atsea-test get configmap dbconfig -o yaml
apiVersion: v1
data:
  db: atsea
  user: gordonuser
kind: ConfigMap
metadata:
  creationTimestamp: "2019-02-22T17:32:14Z"
  name: dbconfig
  namespace: default
```

## Create secret.yaml, deploy it and test it.

```bash
$ kubectl apply -f secret.yaml
secret/atsea-postgres-password created

# Verify password 
$ kubectl -n atsea-test get secret atsea-postgres-password -o yaml
apiVersion: v1
data:
  password: Z29yZG9ucGFzcw==
kind: Secret
metadata:
  name: atsea-postgres-password
  namespace: default

# Look at password - scary! It is just base64 encoded!
$ echo 'Z29yZG9ucGFzcw==' | base64 --decode
gordonpass
```

## Create a secret for Kube to access DTR

To pull private DTR images with Kubernetes, you may need to put your DTR credentials to a secret so Kube can authenticate with DTR. The DB and Webapp pod deplyments will access them with imagePullSecrets: name: regcred.

```bash
$ kubectl create secret -n atsea-test docker-registry regcred --docker-server=dtr.mydomain.com --docker-username=admin --docker-password=xxxxxxxxx --docker-email=someuser@mydomain.com
```

## Create db deployment

```bash
$ kubectl apply -f db-pod.yaml
deployment.apps/atsea-database created

$ kubectl -n atsea-test get pods
NAME                              READY   STATUS    RESTARTS   AGE
atsea-database-6bf74cbc4b-7n5d7   1/1     Running   0          25s

# use your pod name from the output of kubectl get pods here!
$ kubectl describe pod/atsea-database-6bf74cbc4b-7n5d7
Name:           atsea-database-6bf74cbc4b-7n5d7
Namespace:      default
Node:           docker-for-desktop/192.168.65.3
<...>

Events:
  Type    Reason                 Age   From                         Message
  ----    ------                 ----  ----                         -------
  Normal  Scheduled              57s   default-scheduler            Successfully assigned atsea-database-6bf74cbc4b-7n5d7 to docker-for-desktop
  Normal  SuccessfulMountVolume  57s   kubelet, docker-for-desktop  MountVolume.SetUp succeeded for volume "default-token-wmj5r"
  Normal  Pulled                 56s   kubelet, docker-for-desktop  Container image "dtr.mydomain.com/test/atsea-db_build:RC-test" already present on machine
  Normal  Created                56s   kubelet, docker-for-desktop  Created container
  Normal  Started                55s   kubelet, docker-for-desktop  Started container

# Again, use your pod name
$ kubectl logs pod/atsea-database-6bf74cbc4b-7n5d7
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
<...>

$ kubectl apply -f db-service.yaml
service/database created

$ kubectl -n atsea-test describe svc/database
Name:              database
Namespace:         default
Labels:            run=atsea-database
Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                     {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"run":"atsea-database"},"name":"database","namespace":"default"...
Selector:          run=atsea-database
Type:              ClusterIP
IP:                10.109.222.29
Port:              http  5432/TCP
TargetPort:        5432/TCP
Endpoints:         10.1.0.28:5432
Session Affinity:  None
Events:            <none>

$ kubectl apply -f webapp-pod.yaml
deployment.apps/atsea-web created

$ kubectl apply -f webapp-service.yaml
service/atsea-webapp created

$ kubectl -n atsea-test get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
atsea-webapp   NodePort    10.104.35.106   <none>        8080:32666/TCP   29s
database       ClusterIP   10.109.43.119   <none>        5432/TCP         1m
```

### Misc degugging commands used

$ kubectl apply -f create-app-namespace.yaml
namespace/atsea-test created

kubectl config set-context $(kubectl config current-context) --namespace=default

$ kubectl exec -it atsea-database-74f677ff46-qjmg5 -- psql -U gordonuser -d atsea

$ kubectl create secret -n atsea-test docker-registry regcred --docker-server=dtr.mydomain.com --docker-username=admin --docker-password=xxxxxxxxx --docker-email=sysadmin@mydomain.com