#!/bin/bash

# Step 1: Run Infrastructure as Code
cd infrastructure/terraform
terraform init
terraform apply --auto-approve
aws eks update-kubeconfig --name my-eks-cluster
kubectl config view


# Step 2: Install Jenkins on Kubernetes
cd ../kubernetes
kubectl create ns jenkins
kubectl apply -f jenkins-deployment.yaml -n jenkins
kubectl apply -f jenkins-service.yaml -n jenkins


echo "Setup complete!"