
resource "aws_ecr_repository" "aws-ecr" {
  name = var.ecr_repo

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "${var.appname}-ecr"
    Environment = var.appenv
  }
}
