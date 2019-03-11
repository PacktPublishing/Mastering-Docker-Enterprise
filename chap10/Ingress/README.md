# Set Up Docker EE Kubernetes Ingress

## Use Helm to install the ingress controller

Here are the docs: <https://kubernetes.github.io/ingress-nginx/deploy/#using-helm>

### Install the Helm Chart

```bash
$ helm install stable/nginx-ingress --name my-nginx --set rbac.create=true
```

You will see the initial status after the install, but you wait about 5 minutes for help to complete the deployment.

### Check the status after 5 minutes

```bash
$ helm status my-nginx
LAST DEPLOYED: Sun Feb 24 04:34:34 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/ClusterRole
NAME                    AGE
my-nginx-nginx-ingress  6h28m

==> v1beta1/ClusterRoleBinding
NAME                    AGE
my-nginx-nginx-ingress  6h28m

==> v1beta1/Role
NAME                    AGE
my-nginx-nginx-ingress  6h28m

==> v1beta1/RoleBinding
NAME                    AGE
my-nginx-nginx-ingress  6h28m

==> v1/ConfigMap
NAME                               DATA  AGE
my-nginx-nginx-ingress-controller  1     6h28m

==> v1/Service
NAME                                    TYPE          CLUSTER-IP     EXTERNAL-IP  PORT(S)                     AGE
my-nginx-nginx-ingress-controller       LoadBalancer  10.96.154.150  <pending>    80:33394/TCP,443:34275/TCP  6h28m
my-nginx-nginx-ingress-default-backend  ClusterIP     10.96.18.88    <none>       80/TCP                      6h28m

==> v1beta1/Deployment
NAME                                    DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
my-nginx-nginx-ingress-controller       1        1        1           1          6h28m
my-nginx-nginx-ingress-default-backend  1        1        1           1          6h28m

==> v1/Pod(related)
NAME                                                    READY  STATUS   RESTARTS  AGE
my-nginx-nginx-ingress-controller-5655d75c9c-9r5h5      1/1    Running  0         6h28m
my-nginx-nginx-ingress-default-backend-898d5489b-t5m7x  1/1    Running  0         6h28m

==> v1/ServiceAccount
NAME                    SECRETS  AGE
my-nginx-nginx-ingress  1        6h28m
```

## Deploy the dockerdemo test pod and ClusterIP service

```
$ kubectl apply -f ingress-test-app.yaml
service/docker-demo-svc created

$ kubectl apply -f ingress-test-conf.yaml
ingress.extensions/dockerdemo-ingress created

$ kubectl get ingress
NAME                 HOSTS                      ADDRESS   PORTS   AGE
dockerdemo-ingress   ingress-app.mydomain.com             80      3h
```

## Use cURL to verify routing

```bash
$ curl -H "Host: ingress-app.mydomain.com " http://10.10.1.39:33394
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title></title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
        <meta name="author" content="Evan Hazlett">
        <meta name="description" content="Docker Demo">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
        <link rel="stylesheet" type="text/css" href="static/dist/semantic.min.css">
        <link rel="stylesheet" type="text/css" href="static/css/default.css">
        <script src="static/dist/semantic.min.js"></script>
        ...
```
