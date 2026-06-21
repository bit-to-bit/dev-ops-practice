resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

    tags = {
    Name        = "Terraform ECR for Docker"
    Environment = "lesson-8-9"
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPushPull",
        Effect = "Allow",
        Principal = {
          AWS = formatlist("arn:aws:iam::%s:root", var.allowed_account_ids)
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}