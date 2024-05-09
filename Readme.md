# Assumptions and Prerequisites:
You have the AWS CLI installed and configured with appropriate permissions.
kubectl is installed and configured to interact with your Kubernetes cluster.
Terraform is installed on your system.
You have the necessary IAM permissions to create resources like EKS clusters, IAM roles, etc.
Script (automation.sh):

#!/bin/bash

# Terraform variables
export AWS_REGION="us-west-2"
export EKS_CLUSTER_NAME="my-eks-cluster"
export CI_CD_TOOL_NAMESPACE="jenkins"
export MICROSERVICE_NAME="my-microservice"

# Step 1: Provision EKS cluster using Terraform
echo "Provisioning EKS cluster..."
terraform init
terraform apply -auto-approve

# Step 2: Update kubeconfig with EKS cluster details
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

# Step 3: Install Jenkins in Kubernetes
echo "Installing Jenkins in Kubernetes..."
kubectl create namespace $CI_CD_TOOL_NAMESPACE
kubectl apply -f jenkins-deployment.yaml -n jenkins
kubectl apply -f jenkins-service.yaml -n jenkins

# Step 4: Create pipeline for microservice in Jenkins
echo "Creating pipeline for $MICROSERVICE_NAME in Jenkins..."
JENKINS_PASSWORD=$(kubectl exec $(kubectl get pods -n $CI_CD_TOOL_NAMESPACE -l "app.kubernetes.io/component=jenkins-master" -o jsonpath="{.items[0].metadata.name}") -n $CI_CD_TOOL_NAMESPACE -- cat /run/secrets/chart-admin-password)
JENKINS_URL="http://jenkins.$CI_CD_TOOL_NAMESPACE.svc.cluster.local:8080"
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
                  sh "echo Building $MICROSERVICE_NAME"
                }
              }
              stage('Deploy') {
                steps {
                  sh "echo Deploying $MICROSERVICE_NAME"
                }
              }
            }
          }" | java -jar /usr/share/jenkins/jenkins-cli.jar -auth admin:$JENKINS_PASSWORD -s $JENKINS_URL create-job $MICROSERVICE_NAME'
      restartPolicy: Never
EOF

# Step 5: Trigger pipeline execution
echo "Triggering pipeline execution for $MICROSERVICE_NAME..."
kubectl create job --from=cronjob/create-pipeline $MICROSERVICE_NAME-pipeline

echo "Script execution complete."
Explanation:
Terraform Deployment:
Initializes Terraform and provisions the EKS cluster using your Terraform configuration.
Kubeconfig Update:
Updates the kubeconfig file to include the newly created EKS cluster.
CI/CD Tool Installation:
Creates a namespace for Jenkins (jenkins).
Installs Jenkins in the jenkins namespace using the Helm chart.
Pipeline Creation:
Retrieves Jenkins credentials and URL.
Uses kubectl exec to execute a script in the Jenkins container to create a pipeline job for your microservice.
Pipeline Execution:
Triggers the pipeline execution using a Kubernetes Job.
Usage:
Ensure the script is executable:
chmod +x deploy.sh
Execute the script:
./automation.sh

Notes:
Replace placeholders ($AWS_REGION, $EKS_CLUSTER_NAME, $CI_CD_TOOL_NAMESPACE, $MICROSERVICE_NAME) with your desired values.
Modify the pipeline script (pipeline {} block) in the Kubernetes Job YAML to define your actual build and deploy steps.
This script demonstrates an automated workflow but may require adjustments based on your specific requirements and environment setup.
Before running this script in a production environment, thoroughly test and validate each step to ensure it aligns with your infrastructure and security policies. 