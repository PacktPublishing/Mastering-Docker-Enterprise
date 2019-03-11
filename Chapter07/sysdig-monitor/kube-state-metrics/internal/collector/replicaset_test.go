/*
Copyright 2016 The Kubernetes Authors All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package collector

import (
	"testing"
	"time"

	"k8s.io/api/extensions/v1beta1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/kube-state-metrics/pkg/metric"
)

var (
	rs1Replicas int32 = 5
	rs2Replicas int32 = 0
)

func TestReplicaSetCollector(t *testing.T) {
	// Fixed metadata on type and help text. We prepend this to every expected
	// output so we only have to modify a single place when doing adjustments.
	var test = true

	const metadata = `
		# HELP kube_replicaset_created Unix creation timestamp
		# TYPE kube_replicaset_created gauge
	  # HELP kube_replicaset_metadata_generation Sequence number representing a specific generation of the desired state.
		# TYPE kube_replicaset_metadata_generation gauge
		# HELP kube_replicaset_status_replicas The number of replicas per ReplicaSet.
		# TYPE kube_replicaset_status_replicas gauge
		# HELP kube_replicaset_status_fully_labeled_replicas The number of fully labeled replicas per ReplicaSet.
		# TYPE kube_replicaset_status_fully_labeled_replicas gauge
		# HELP kube_replicaset_status_ready_replicas The number of ready replicas per ReplicaSet.
		# TYPE kube_replicaset_status_ready_replicas gauge
		# HELP kube_replicaset_status_observed_generation The generation observed by the ReplicaSet controller.
		# TYPE kube_replicaset_status_observed_generation gauge
		# HELP kube_replicaset_spec_replicas Number of desired pods for a ReplicaSet.
		# TYPE kube_replicaset_spec_replicas gauge
		# HELP kube_replicaset_owner Information about the ReplicaSet's owner.
		# TYPE kube_replicaset_owner gauge
		# HELP kube_replicaset_labels Kubernetes labels converted to Prometheus labels.
		# TYPE kube_replicaset_labels gauge
	`
	cases := []generateMetricsTestCase{
		{
			Obj: &v1beta1.ReplicaSet{
				ObjectMeta: metav1.ObjectMeta{
					Name:              "rs1",
					CreationTimestamp: metav1.Time{Time: time.Unix(1500000000, 0)},
					Namespace:         "ns1",
					Generation:        21,
					OwnerReferences: []metav1.OwnerReference{
						{
							Kind:       "Deployment",
							Name:       "dp-name",
							Controller: &test,
						},
					},
					Labels: map[string]string{
						"app": "example1",
					},
				},
				Status: v1beta1.ReplicaSetStatus{
					Replicas:             5,
					FullyLabeledReplicas: 10,
					ReadyReplicas:        5,
					ObservedGeneration:   1,
				},
				Spec: v1beta1.ReplicaSetSpec{
					Replicas: &rs1Replicas,
				},
			},
			Want: `
				kube_replicaset_labels{replicaset="rs1",namespace="ns1",label_app="example1"} 1
				kube_replicaset_created{namespace="ns1",replicaset="rs1"} 1.5e+09
				kube_replicaset_metadata_generation{namespace="ns1",replicaset="rs1"} 21
				kube_replicaset_status_replicas{namespace="ns1",replicaset="rs1"} 5
				kube_replicaset_status_observed_generation{namespace="ns1",replicaset="rs1"} 1
				kube_replicaset_status_fully_labeled_replicas{namespace="ns1",replicaset="rs1"} 10
				kube_replicaset_status_ready_replicas{namespace="ns1",replicaset="rs1"} 5
				kube_replicaset_spec_replicas{namespace="ns1",replicaset="rs1"} 5
				kube_replicaset_owner{namespace="ns1",owner_is_controller="true",owner_kind="Deployment",owner_name="dp-name",replicaset="rs1"} 1
`,
		},
		{
			Obj: &v1beta1.ReplicaSet{
				ObjectMeta: metav1.ObjectMeta{
					Name:       "rs2",
					Namespace:  "ns2",
					Generation: 14,
					Labels: map[string]string{
						"app": "example2",
						"env": "ex",
					},
				},
				Status: v1beta1.ReplicaSetStatus{
					Replicas:             0,
					FullyLabeledReplicas: 5,
					ReadyReplicas:        0,
					ObservedGeneration:   5,
				},
				Spec: v1beta1.ReplicaSetSpec{
					Replicas: &rs2Replicas,
				},
			},
			Want: `
				kube_replicaset_labels{replicaset="rs2",namespace="ns2",label_app="example2",label_env="ex"} 1
				kube_replicaset_metadata_generation{namespace="ns2",replicaset="rs2"} 14
				kube_replicaset_status_replicas{namespace="ns2",replicaset="rs2"} 0
				kube_replicaset_status_observed_generation{namespace="ns2",replicaset="rs2"} 5
				kube_replicaset_status_fully_labeled_replicas{namespace="ns2",replicaset="rs2"} 5
				kube_replicaset_status_ready_replicas{namespace="ns2",replicaset="rs2"} 0
				kube_replicaset_spec_replicas{namespace="ns2",replicaset="rs2"} 0
				kube_replicaset_owner{namespace="ns2",owner_is_controller="<none>",owner_kind="<none>",owner_name="<none>",replicaset="rs2"} 1
			`,
		},
	}
	for i, c := range cases {
		c.Func = metric.ComposeMetricGenFuncs(replicaSetMetricFamilies)
		if err := c.run(); err != nil {
			t.Errorf("unexpected collecting result in %vth run:\n%s", i, err)
		}

	}
}
