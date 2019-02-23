# UCP Helm Setup

Helm Docs are here: <https://helm.sh/docs/>

```bash
$ ./create-rbac-ucp.sh

$ kubectl create -f rbac-config.yaml

$ ./get_helm.sh

$ helm init --service-account tiller
```

