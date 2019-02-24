# UCP Helm Setup

Helm Docs are here: <https://helm.sh/docs/>

```bash
$ ./create-rbac-ucp.sh

$ kubectl create -f rbac-config.yaml

$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh

$  chmod 700 get_helm.sh

$ ./get_helm.sh

$ helm init --service-account tiller
```

