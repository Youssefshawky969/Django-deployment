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

resource "aws_ecs_service" "django" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.django.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs.id]

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.django.arn
    container_name   = "django-app"
    container_port   = 8000

  }

depends_on = [aws_lb_listener.http]

}
