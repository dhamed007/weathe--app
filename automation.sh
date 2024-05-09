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

# Step 3: Create Jenkins Pipeline
# This step should involve Jenkins API calls or CLI commands to create the pipeline from Jenkinsfile in the repo

# Step 4: Execute Jenkins Pipeline
# Trigger Jenkins build for the microservice, either via Jenkins API or CLI

echo "Setup complete!"