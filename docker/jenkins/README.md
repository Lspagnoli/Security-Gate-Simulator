# EC2 Jenkins Docker Setup

## Overview

This project contains a `Dockerfile` and a `docker-compose.yml` file used to deploy and run a Jenkins pipeline on an AWS EC2 instance.

The purpose of this setup is to provide a consistent, containerized Jenkins environment that can be easily deployed, reproduced, and managed on EC2.

---

## Components

### Dockerfile

The `Dockerfile` defines the custom Jenkins image used in this setup. It typically includes:

* A base Jenkins image
* Required plugins
* Custom configurations
* Any additional dependencies needed for builds or pipelines

This ensures that every time the container is built, Jenkins is configured in a consistent way.

---

### docker-compose.yml

The `docker-compose.yml` file is responsible for:

* Building the Docker image from the Dockerfile
* Running the Jenkins container
* Mapping ports (e.g., 8080 for Jenkins UI)
* Mounting volumes for persistent Jenkins data
* Defining environment variables if needed

Using Docker Compose simplifies container management and allows the Jenkins service to be started with a single command.

---

## Deployment on AWS EC2

### Prerequisites

* An active EC2 instance
* Docker installed on the instance
* Docker Compose installed on the instance
* Proper security group rules (e.g., port 8080 open for Jenkins UI)

---

### Steps to Deploy

1. Transfer project files to EC2 (via SCP, Git, or rsync)

2. SSH into the EC2 instance:

   ```bash
   ssh -i your-key.pem ec2-user@your-ec2-ip
   ```

3. Navigate to the project directory:

   ```bash
   cd your-project-directory
   ```

4. Build and start Jenkins using Docker Compose:

   ```bash
   docker compose up -d --build
   ```

5. Access Jenkins:

   * Open a browser and go to:

     ```
     http://your-ec2-ip:8080
     ```

---

## Jenkins Pipeline Usage

Once Jenkins is running:

* Create or configure a pipeline job
* Connect it to your source repository (GitHub, GitLab, etc.)
* Define your pipeline (Jenkinsfile)
* Run builds directly from the Jenkins UI

The containerized setup ensures pipelines run in a controlled and reproducible environment.

---

## Benefits of This Setup

* Consistent Jenkins environment across deployments
* Easy to rebuild and redeploy
* Isolated containerized execution
* Simplified management using Docker Compose
* Ideal for CI/CD workflows on EC2

---

## Notes

* Ensure your EC2 instance has sufficient resources (CPU, RAM, disk)
* Persist Jenkins data using Docker volumes to avoid data loss
* Consider securing Jenkins with authentication and HTTPS for production use

---

## Summary

This Docker-based setup allows you to quickly deploy Jenkins on an EC2 instance and use it to run CI/CD pipelines. The combination of a Dockerfile and docker-compose ensures a repeatable and maintainable infrastructure for your automation workflows.
