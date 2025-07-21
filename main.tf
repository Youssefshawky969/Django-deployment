provider "aws" {
  region = var.aws_region
}



terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Youssef-shawky"
    workspaces {
      name = "ecs-task"
    }
  }
}
