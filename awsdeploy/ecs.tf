
resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.appname_short}-cluster"
  tags = {
    Name = "${var.appname_short}-ecs"
    Environment = var.appenv
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.appname_short}-${var.appenv}-logs"
  tags = {
    Authentication = var.appname
    Environment = var.appenv
  }
}

data "template_file" "env_vars" {
  template = file("env_vars.json")
}

data "template_file" "container_def" {
  template = file("containerdef.json")

  vars = {
    shortname = var.appname_short
    repourl = aws_ecr_repository.aws-ecr.repository_url
    env = data.template_file.env_vars.rendered
    cwgroup = aws_cloudwatch_log_group.log-group.id
    region = var.aws_region
    appname = var.appname
    appenv = var.appenv
    appversion = var.appversion
  }
}

#output "containerdef_rendered" {
#  value = data.template_file.container_def.rendered
#}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.appname_short}-task"

  container_definitions = data.template_file.container_def.rendered

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory = "512"
  cpu = "256"
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  
  tags = {
    Name = "${var.appname_short}-ecs"
    Environment = var.appenv
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name = "${var.appname_short}-ecs-service"
  cluster = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"

  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count = 1

  # to update the docker image forcefully, if our environment already exists
  force_new_deployment = true

  network_configuration {
    subnets = aws_subnet.mc-public.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service-sg.id,
      aws_security_group.load_balancer_sg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = "${var.appname_short}-app-container"
    container_port = 80
  }

  depends_on = [aws_lb_listener.listener]
}

resource "aws_security_group" "service-sg" {
  vpc_id = aws_vpc.service-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [
      aws_security_group.load_balancer_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.appname_short}-service-sg"
    Environment = var.appenv
  }
}
