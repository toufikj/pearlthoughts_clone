resource "aws_ecs_cluster" "ecs" {
  name = "toufikj-strapi"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create CloudWatch Log Group for Strapi
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.stage}/${var.product}"
  retention_in_days = 7
}

# Create ECS Task Definition for Strapi
resource "aws_ecs_task_definition" "ecs" {
  family                   = "${var.stage}-${var.product}-task"
  task_role_arn            = var.existing_ecs_task_execution_role_arn
  execution_role_arn       = var.existing_ecs_task_execution_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image_uri
    essential = true
    portMappings = [{
      containerPort = var.container_port
      protocol      = var.container_protocol
    }]
    environment = [
      {
        name  = "SERVICE"
        value = tostring(var.container_port)
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = var.stage
      }
    }
  }])
}

# Create Target Group for Flowise ECS Service
resource "aws_lb_target_group" "ecs" {
  name        = "${var.stage}-${var.product}-tg-blue"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/admin"
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200-299"
  }
}
resource "aws_lb_target_group" "ecs_green" {
  name        = "${var.stage}-${var.product}-tg-green"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/admin"
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200-299"
  }
}
resource "aws_lb_listener_rule" "ecs" {
  listener_arn = var.existing_listener_arn # Use the ARN of the existing listener on port 443
  priority     = var.listener_priority     # Set a priority, e.g., 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}  


# Create ECS Service for Strapi
resource "aws_ecs_service" "ecs" {
  name            = "${var.stage}-${var.product}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  enable_execute_command   = true
  enable_ecs_managed_tags  = true
  propagate_tags           = "SERVICE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  network_configuration {
    subnets         = var.private_subnets
    security_groups = var.security_group
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_iam_role" "codedeploy_ecs_role" {
  name = "toufikj-CodeDeployECSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codedeploy_ecs_policy" {
  name = "toufikj-CodeDeployECSPolicy"
  role = aws_iam_role.codedeploy_ecs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeClusters"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "iam:PassRole"
        ],
        Resource = "*",
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow",
        Action   = [
          "codedeploy:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_codedeploy_app" "ecs" {
  name              = "${var.stage}-${var.product}-codedeploy-app"
  compute_platform  = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = aws_codedeploy_app.ecs.name
  deployment_group_name = "${var.stage}-${var.product}-dg"
  service_role_arn      = "arn:aws:iam::607700977843:role/CodeDeployECSBlueGreen"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = "toufikj-strapi"
    service_name = aws_ecs_service.ecs.name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.ecs.name
      }

      target_group {
        name = aws_lb_target_group.ecs_green.name
      }

      prod_traffic_route {
        listener_arns = [var.existing_listener_arn]
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}