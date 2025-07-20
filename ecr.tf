resource "aws_ecr_repository" "django" {
  name = var.app_name
  force_delete = true

}