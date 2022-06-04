
resource "aws_security_group" "sg" {
  name        = "${var.name}-${var.env}"
  description = "Allow price ports within the VPC, and browsing from the outside"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Change this to your own IP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_ecs_cluster" "cluster" {
  name               = "${var.name}-${var.env}"
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

resource "aws_ecs_task_definition" "ecs-task" {
  family                = "${var.name}-${var.env}"
  network_mode          = "awsvpc"
  container_definitions = "${file("${var.env_variables}")}"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
}

resource "aws_ecs_service" "ecs-service" {
  name          = "${var.name}-${var.env}"
  cluster       = aws_ecs_cluster.cluster.id
  desired_count = 1
  health_check_grace_period_seconds = 600
  network_configuration {
    subnets          = var.subnet_public_ids
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.ecs-task.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "${var.name}-${var.env}"
    container_port   = 80
  }

  depends_on = [aws_lb_target_group.tg, aws_lb.elb]
}
