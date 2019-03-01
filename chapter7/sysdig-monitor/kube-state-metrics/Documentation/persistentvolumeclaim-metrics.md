# PersistentVolumeClaim Metrics

| Metric name| Metric type | Labels/tags | Status |
| ---------- | ----------- | ----------- | ----------- |
| kube_persistentvolumeclaim_info | Gauge | `namespace`=&lt;persistentvolumeclaim-namespace&gt; <br> `persistentvolumeclaim`=&lt;persistentvolumeclaim-name&gt; <br> `storageclass`=&lt;persistentvolumeclaim-storageclassname&gt;<br>`volumename`=&lt;volumename&gt; | STABLE |
| kube_persistentvolumeclaim_labels | Gauge | `persistentvolumeclaim`=&lt;persistentvolumeclaim-name&gt; <br> `namespace`=&lt;persistentvolumeclaim-namespace&gt; <br> `label_PERSISTENTVOLUMECLAIM_LABEL`=&lt;PERSISTENTVOLUMECLAIM_LABEL&gt;  | STABLE |
| kube_persistentvolumeclaim_status_phase | Gauge | `namespace`=&lt;persistentvolumeclaim-namespace&gt; <br> `persistentvolumeclaim`=&lt;persistentvolumeclaim-name&gt; <br> `phase`=&lt;Pending\|Bound\|Lost&gt; | STABLE |
| kube_persistentvolumeclaim_resource_requests_storage_bytes | Gauge | `namespace`=&lt;persistentvolumeclaim-namespace&gt; <br> `persistentvolumeclaim`=&lt;persistentvolumeclaim-name&gt; | STABLE |

Note:

- A special `<none>` string will be used if PVC has no storage class.
