# We need a policy to enable the service to pull the image from ECR

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "${var.appname_short}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  tags = {
    Name = "${var.appname_short}-iam-role"
    Environment = var.appenv
  }
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy-ECSTask" {
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy-CW" {
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_iam_policy_document" "ecr-access" {
  statement {
    sid = "ECR-Access"
    principals {
      type = "AWS"
      identifiers = [aws_iam_role.ecsTaskExecutionRole.arn]
    }
    actions = ["ecr:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "s3-dkr-access" {
  statement {
    sid = "S3-DKR-Access"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::prod-${var.aws_region}-starport-layer-bucket/*"]
    principals {
      type = "*"
      identifiers = ["*"]
    }
#    principals {
#      type = "AWS"
#      identifiers = [aws_iam_role.ecsTaskExecutionRole.arn]
#    }
    effect = "Allow"
#    condition {
#      test = "ArnEquals"
#      variable = "aws:PrincipalArn"
#      values = [aws_iam_role.ecsTaskExecutionRole.arn]
#    }
  }
}

# We allow ecr, s3/dkr, and disallow everything else S3
data "aws_iam_policy_document" "s3-ecr-access" {
  source_policy_documents = [
    data.aws_iam_policy_document.ecr-access.json,
    data.aws_iam_policy_document.s3-dkr-access.json
  ]
}

