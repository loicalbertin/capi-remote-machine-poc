#!/usr/bin/env bash

kind delete clusters capi-management

kind create cluster --name capi-management

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml

kubectl -n cert-manager wait --timeout="-1s" --for=condition=Available  deploy/cert-manager
kubectl -n cert-manager wait --timeout="-1s" --for=condition=Available  deploy/cert-manager-webhook
kubectl -n cert-manager wait --timeout="-1s" --for=condition=Available  deploy/cert-manager-cainjector

kubectl apply --server-side=true -f https://docs.k0smotron.io/stable/install.yaml

kubectl apply --server-side -k .

kubectl -n k0smotron wait --timeout="-1s" --for=condition=Available  deploy/k0smotron-controller-manager

clusterctl init --infrastructure k0sproject-k0smotron --bootstrap kubeadm --control-plane kubeadm

kubectl -n k0smotron wait --timeout="-1s" --for=condition=Available  deploy/k0smotron-controller-manager-infrastructure
kubectl -n capi-system wait --timeout="-1s" --for=condition=Available  deploy/capi-controller-manager  
kubectl -n capi-kubeadm-bootstrap-system wait --timeout="-1s" --for=condition=Available  deploy/capi-kubeadm-bootstrap-controller-manager  
kubectl -n capi-kubeadm-control-plane-system wait --timeout="-1s" --for=condition=Available  deploy/capi-kubeadm-control-plane-controller-manager  


#kubectl apply -f cluster.yaml 
