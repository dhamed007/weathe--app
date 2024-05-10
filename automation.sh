#!/bin/bash

# Set Terraform variables
export AWS_REGION="us-west-2"
export EKS_CLUSTER_NAME="my-eks-cluster"
export CI_CD_TOOL_NAMESPACE="jenkins"
export MICROSERVICE_NAME="my-microservice"

# Step 1: Provision EKS cluster using Terraform
echo "Step 1: Provisioning EKS cluster..."
cd infrastructure/terraform
terraform init
terraform apply --auto-approve


# Step 2: Update kubeconfig with EKS cluster details
echo "Step 2: Updating kubeconfig..."
#aws eks update-kubeconfig --name $EKS_CLUSTER_NAME 
aws eks update-kubeconfig --name my-eks-cluster

# Step 3: Install Jenkins (or your preferred CI/CD tool) in Kubernetes
echo "Step 3: Installing Jenkins in Kubernetes..."
cd ../kubernetes
kubectl create ns jenkins

# Install Jenkins in the specified namespace
kubectl apply -f jenkins-deployment.yaml -n jenkins
kubectl apply -f jenkins-service.yaml -n jenkins

# Step 4: Create pipeline for microservice in Jenkins
echo "Step 4: Creating pipeline for $MICROSERVICE_NAME in Jenkins..."
JENKINS_PASSWORD=$(kubectl get secret --namespace $CI_CD_TOOL_NAMESPACE jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
JENKINS_URL="http://jenkins.$CI_CD_TOOL_NAMESPACE.svc.cluster.local:8080"

# Use Jenkins CLI to create a pipeline job for the microservice
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: create-pipeline
spec:
  template:
    spec:
      containers:
      - name: jenkins-cli
        image: jenkins/jenkins
        command:
        - sh
        - -c
        - 'echo "pipeline {
            agent any
            stages {
              stage('Build') {
                steps {
                  cd ./microservice
                  sh \"docker build -t microservice .\"
                 
                }
              }
              stage('Deploy') {
                steps {
                  sh \"kubectl apply -f deployment.yaml\"
                 
                }
              }
            }
          }" | java -jar /usr/share/jenkins/jenkins-cli.jar -auth admin:$JENKINS_PASSWORD -s $JENKINS_URL create-job $MICROSERVICE_NAME'
      restartPolicy: Never
EOF

# Step 5: Trigger pipeline execution
echo "Step 5: Triggering pipeline execution for $MICROSERVICE_NAME..."

# Retrieve Jenkins URL and credentials
JENKINS_URL="http://jenkins.$CI_CD_TOOL_NAMESPACE.svc.cluster.local:8080"
JENKINS_USER="admin"  # Assuming the Jenkins admin username
JENKINS_PASSWORD=$(kubectl get secret --namespace $CI_CD_TOOL_NAMESPACE jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)

# Trigger Jenkins pipeline build using Jenkins CLI
java -jar /usr/share/jenkins/jenkins-cli.jar -auth $JENKINS_USER:$JENKINS_PASSWORD -s $JENKINS_URL build $MICROSERVICE_NAME


echo "Script execution complete."