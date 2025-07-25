# Deploy Django Application Deployment on AWS ECS Fargate Using GitHub Actions for CI/CD

### Architecture
<img width="1345" height="900" alt="Architecture" src="https://github.com/user-attachments/assets/e7570387-3a54-487b-a275-38847f536b6e" />

### Overview

This project show how to deploy a Django application to AWS ECS using GitHub Actions for CI/CD. The setup includes:
- Dockerized Django app
- Terraform-managed AWS infrastructure
- ECS Fargate service behind an Application Load Balancer
- CI/CD pipeline triggered via GitHub Actions
- Secure every process

### Tech Stack

- Django: Web framework for the backend application
- Docker: Containerization
- Terraform: Infrastructure as Code (IaC)
- AWS ECS (Fargate): Container orchestration and deployment
- Amazon RDS: PostgreSQL database
- GitHub Actions: CI/CD pipeline automation

### CI/CD Pipeline Process
The CI/CD pipeline is divided into three main jobs:

1. Test:
   By using python unittest

2. Infrastructure

Provisions AWS resources using Terraform
Creates ECR repository and ECS service
Build

3. Builds & Push the Docker image
  - Saves it as an artifact
    Push

  - Downloads the image
  - Tags and pushes it to ECR
  - ECS service pulls the new image on deploy


Cancel the Workflow
##  Requirements

- AWS CLI configured
- Docker installed
- Terraform CLI v1.3+


##  Project Structure

```bash
.
├── core/                      # Django app folder
├── myproject/                 # Django project settings
├── venv/                      # Python virtual environment (ignored in Git)
├── db.sqlite3                 # Local dev DB (ignored in prod)
├── manage.py                  # Django CLI entry point
├── docker/
│   └── Dockerfile             # Docker build file
├── terraform/
│   ├── main.tf                # Root orchestrator (includes or references others)
│   ├── variables.tf           # All variable declarations
│   ├── outputs.tf             # Output ALB DNS, ECS info, etc.
│   ├── vpc.tf                 # VPC, subnets, IGW
│   ├── alb.tf                 # ALB, target group, listener
│   ├── ecs.tf                 # ECS cluster, task definition, service
│   ├── iam.tf                 # ECS task role and policies
│   ├── ecr.tf                 # ECR repository
│   ├── endpoints.tf           # VPC Interface Endpoints
│   └── security.tf            # Security groups for ALB and ECS
├── README.md                  # Project documentation

```


### How to use:

1. Configure Secrets
   Set the following GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

2.Trigger Workflow

  Run the Build & Deploy Django to ECS workflow automatically on every change in the code.

