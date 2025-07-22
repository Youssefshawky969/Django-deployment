variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "django-app"
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

