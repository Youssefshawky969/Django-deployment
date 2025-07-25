# Deploy Django Application Deployment on AWS ECS Fargate Using GitHub Actions for CI/CD

### Architecture:
<img width="1355" height="830" alt="download" src="https://github.com/user-attachments/assets/30a8f1af-edfb-4cfe-8fbe-435781ef20dc" />



### Overview:

This project show how to deploy a Django application to AWS ECS using GitHub Actions for CI/CD. The setup includes:
- Dockerized Django app
- Terraform-managed AWS infrastructure
- ECS Fargate service behind an Application Load Balancer
- CI/CD pipeline triggered via GitHub Actions
- Secure every process

### Tech Stack:

- Django: Web framework for the backend application
- Docker: Containerization
- Terraform: Infrastructure as Code (IaC)
- AWS ECS (Fargate): Container orchestration and deployment
- Amazon RDS: PostgreSQL database
- GitHub Actions: CI/CD pipeline automation

### CI/CD Pipeline Process:
The CI/CD pipeline is divided into three main jobs:

#### 1. Test:
   By using python unittest

#### 2. Infrastructure

Provisions AWS resources using Terraform
Creates ECR repository and ECS service
Build

#### 3. Builds & Push the Docker image
  - Saves it as an artifact
    Push

  - Downloads the image
  - Tags and pushes it to ECR
  - ECS service pulls the new image on deploy

###  Requirements

- AWS CLI configured
- Docker installed
- Terraform CLI v1.3+

### How to use:

#### 1. Configure Secrets
   Set the following GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

#### 2.Trigger Workflow

  Run the Build & Deploy Django to ECS workflow automatically on every change in the code.

