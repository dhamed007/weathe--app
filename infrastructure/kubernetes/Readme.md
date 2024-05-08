Jenkins Deployment on Kubernetes
This guide provides step-by-step instructions for deploying Jenkins on Kubernetes using kubectl. Jenkins is an open-source automation server that helps automate the building, testing, and deployment of applications.

Step 1: Creating Jenkins Namespace
kubectl create namespace jenkins
This command creates a Kubernetes namespace named jenkins where Jenkins will be deployed.

Step 2: Deploying Jenkins
Create a YAML file jenkins.yaml and add the following deployment configuration:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
          - name: http-port
            containerPort: 8080
          - name: jnlp-port
            containerPort: 50000
        volumeMounts:
          - name: jenkins-vol
            mountPath: /var/jenkins_vol
      volumes:
        - name: jenkins-vol
          emptyDir: {}
Apply the configuration to create the Jenkins deployment:
kubectl apply -f jenkins.yaml --namespace jenkins

Step 3: Exposing Jenkins via Services
Create a NodePort and a ClusterIP service to expose Jenkins:
Create a file jenkins-service.yaml with the following contents:

apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30000
  selector:
    app: jenkins
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-jnlp
  namespace: jenkins
spec:
  type: ClusterIP
  ports:
    - port: 50000
      targetPort: 50000
  selector:
    app: jenkins
Apply the service configuration:
kubectl apply -f jenkins-service.yaml --namespace jenkins

Step 4: Accessing Jenkins UI
Retrieve the external IP of a node in your Kubernetes cluster:
kubectl get nodes -o wide
Copy the external IP and access Jenkins using the NodePort:
http://<external_ip>:30000

Follow the Jenkins setup instructions to retrieve the administrator password and complete the initial configuration.

Step 5: Running a Sample Pipeline
Navigate to the Jenkins UI.
Click on "New item" in the left-hand menu.
Choose "Pipeline" and click "OK".
Configure the pipeline:
In the Pipeline section, select "Hello World" from the try sample pipeline dropdown menu.
Click "Save" to create the pipeline.
Jenkins will now execute the sample pipeline, demonstrating basic CI/CD capabilities.

This README provides a concise guide to deploying Jenkins on Kubernetes, exposing it via services, accessing the Jenkins UI, and running a sample pipeline. Follow the steps sequentially to set up Jenkins in your Kubernetes environment.