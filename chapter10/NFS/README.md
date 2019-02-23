# Kuberenetes NFS Storage

## Attaching your UCP Kube Cluster to existing on-premeses NFS Server

We use Helm to install NFS provisioner for Kubernetes. The provisioner create dynamically creates persistent volumes when persistent volume claim is made. 

## NFS CLIENT
Our set up is based on the following and REQUIRES AN EXISTING NFS SERVER TO WORK: 
<https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner>


If you DO NOT have an NFS server and want to autoprovsion cloud resources from your Kubernetes cluster there is another chart for that. We do not cover it in the book, but you might want to check it out: <https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner> 


## Procedure

### Be sure to use your own nfs.server and set nfs.path by replacing the {sample values} in the helm install command

```bash
$ helm install --name my-release --set nfs.server={10.50.1.46} --set nfs.path={/var/nfsshare/apps} stable/nfs-client-provisioner
$ kubectl apply -f nfs-pvc.yaml
$ kubectl get pvc
$ kubectl apply -f test-nfs.yaml
$ kubectl get pods
```

