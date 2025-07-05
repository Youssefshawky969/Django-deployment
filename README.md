# Django Application Deployment on AWS ECS Fargate

This project demonstrates how to build a production-ready deployment pipeline for a Django application using the following technologies:

- **Docker** for containerization
- **AWS ECS Fargate** for serverless container hosting
- **Application Load Balancer (ALB)** for public access
- **Terraform** for infrastructure as code (IaC)
- **VPC Interface Endpoints** for secure communication with AWS services.

##  Requirements

- AWS CLI configured
- Docker installed
- Terraform CLI v1.3+


##  Project Structure

```bash
.
├── docker/
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
└── README.md
```

##  Dockerization

### File: `docker/Dockerfile`

Containerizes the Django application using Python 3.11 slim base image.

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "projectname.wsgi:application", "--bind", "0.0.0.0:8000"]
```

> Replace `projectname` with your Django project folder name.

## Terraform Infrastructure

### Key Components Deployed

#### VPC:

Isolated virtual network with private/public subnets

```
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 100)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = { Name = "public-subnet-${count.index}" }

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "private-subnet-${count.index}" }

}
```
#### ECS Cluster:

Fargate-based serverless compute environment

```
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

}

resource "aws_ecs_task_definition" "django" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.django.repository_url}:latest"
      essential = true
      portMappings = [{
        containerport = 8000
        hostport      = 8000
      }]
    }
  ])

}
```
#### Application Load Balancer:

Exposes Django app to the internet

```
resource "aws_lb" "app" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "django" {
  name        = "${var.app_name}-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-300"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django.arn
  }
}
```

#### IAM Roles:

Grants ECS tasks access to ECR and CloudWatch

```
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-ecs-execution-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },

      Action = "sts:AssumeRole"

    }]

  })


}
```

#### VPC Endpoints:

Private access to AWS services from ECS tasks

##### Required Endpoints

- `com.amazonaws.<region>.ecr.api` (Interface) 
Used to call ECR APIs, like: `DescribeRepositories` and `GetAuthorizationToken`
Without this, ECS cannot start your task (auth failure).

- `com.amazonaws.<region>.ecr.dkr` (Interface)
Used to pull the actual Docker image
Communicates with Docker Registry endpoint

- `com.amazonaws.<region>.logs` (Interface)
This allows the task to send logs privately. Otherwise, logs won't appear in CloudWatch

- `com.amazonaws.<region>.s3` (Gateway)
ECR stores image layers in Amazon S3, and the ECS agent downloads them.
So without this the image pull fails mid-way (403 or timeout).

```
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]

}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]

}

resource "aws_vpc_endpoint" "ecr_logs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.ecs.id]

}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_rtb.id]

}
```

### 1. Provision Infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```
### 2. Build & Push Docker Image to ECR

```bash
# Authenticate with ECR
aws ecr get-login-password --region <region> | \
  docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com

# Build and push image
docker build -t django-app .
docker tag django-app:latest <account_id>.dkr.ecr.<region>.amazonaws.com/django-app:latest
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/django-app:latest
```

### 3. Access the App

Once ECS service is up, navigate to the DNS of the ALB:
```
http://<alb-dns-name>
```

