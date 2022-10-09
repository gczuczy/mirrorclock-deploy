# autoscaling on the CPU policy, for example

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = 2
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.aws-ecs-cluster.name}/${aws_ecs_service.aws-ecs-service.name}"

  # https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters
  # this one's is the task count of an ECS
  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name = "${var.appname_short}-cpu-autoscaling"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 80 # % utilization percent, scales up if reaches 80%
    predefined_metric_specification {
      #predefined_metric_type = "ECSServiceaverageCPUUtilization"
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

