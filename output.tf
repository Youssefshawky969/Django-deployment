output "alb_url" {
  value = "http://.${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.django.repository_url

}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name

}