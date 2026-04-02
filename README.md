# Cluster API Proof of Concept with k0smotron

This project demonstrates a Proof of Concept (PoC) combining Kubernetes Cluster API with a control plane and bootstrap managed by kubeadm, while using k0smotron for infrastructure management, specifically RemoteMachine resources to connect to existing VMs.

## Architecture

- **Cluster API (CAPI)**: Manages the lifecycle of Kubernetes clusters
- **kubeadm**: Handles control plane and bootstrap operations
- **k0smotron**: Manages infrastructure using RemoteMachine resources
- **Vagrant with libvirt**: Creates and manages the VMs

## Prerequisites

- Vagrant with libvirt provider
- kubectl
- kind (Kubernetes in Docker)

## Setup Steps

### 1. Create Virtual Machines

Run Vagrant to create the VMs:

```bash
vagrant up
```

This will create two VMs:
- Control plane VM at `192.168.57.10`
- Worker VM at `192.168.57.11`

### 2. Setup Management Cluster

Run the setup script to create a management cluster with Cluster API components:

```bash
./setup-kind.sh
```

This script:
- Creates a kind cluster named `capi-management`
- Installs cert-manager
- Installs k0smotron
- Initializes Cluster API with k0smotron as the infrastructure provider
- Sets up kubeadm for control plane and bootstrap

### 3. Deploy the Cluster

Apply the cluster configuration to create the target cluster on the VMs:

```bash
kubectl apply -f cluster.yaml
```

This will:
- Create a RemoteCluster resource
- Define RemoteMachineTemplates for control plane and worker nodes
- Create PooledRemoteMachine resources for the VMs
- Deploy a KubeadmControlPlane
- Create a Cluster resource
- Deploy worker nodes using MachineDeployment

## Configuration Files

- `Vagrantfile`: Defines the VMs and their provisioning
- `cluster.yaml`: Cluster API manifests for the target cluster
- `setup-kind.sh`: Script to set up the management cluster
- `kustomization.yaml`: Kustomize configuration for Cluster API
- `secret.yaml`: SSH key secret for VM access

## Cleanup

To clean up the resources:

```bash
vagrant destroy -f
kind delete cluster capi-management
```
