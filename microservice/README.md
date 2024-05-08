# weather-app
# Microservice Deployment

This repository contains code for deploying a microservice using Flask and Docker, along with a Jenkins pipeline for CI/CD.

## Project Structure

The project is structured as follows:

microservice/
├── Dockerfile # Dockerfile for building microservice container
├── app/
│ ├── main.py # Main Python code for microservice
│ └── requirements.txt # Python dependencies
├── Jenkinsfile # Jenkins pipeline configuration
└── README.md # Documentation for the microservice

- **Dockerfile**: Specifies the instructions for building the Docker container for the microservice.
- **app/main.py**: Contains the main Python code for the microservice, exposing a REST endpoint `/weather/<location>` to fetch weather data.
- **app/requirements.txt**: Lists Python dependencies required by the microservice.
- **Jenkinsfile**: Defines the Jenkins pipeline configuration for building, testing, and deploying the microservice.
- **README.md**: Documentation file (this file) providing an overview of the project and its components.

## Usage

### Running Locally

1. Ensure you have Python and Docker installed on your system.
2. Clone this repository:
   git clone https://github.com/enochnet/weather-app
   cd microservice

Build the Docker image:
docker build -t microservice .

Run the Docker container:
docker run -p 8080:8080 microservice

Access the microservice at http://localhost:8080/weather/<location>.

Jenkins Pipeline
This project includes a Jenkinsfile defining a CI/CD pipeline for the microservice. The pipeline stages include:

Build: Building the Docker image.
Test: Running tests on the microservice.
Deploy: Deploying the microservice to kubernetes Cluster