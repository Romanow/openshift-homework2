#!/usr/bin/env bash

namespaces=$(oc get namespace | awk 'NR > 1 {print $1;}' | grep -v openshift | grep -v kube)

for namespace in $namespaces; do
  echo "Processing $namespace"
  cat <<EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
  - kind: ServiceAccount
    name: default
    namespace: $namespace
EOF
done
