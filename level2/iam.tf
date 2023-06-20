resource "aws_iam_policy" "s3-access" {
  name        = "${var.project_name}-s3-access"
  description = "This is the policy for s3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      },
    ]
  })
}

resource "aws_iam_role" "main-role" {
  name                = "${var.project_name}-main-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-main-role"
  }
}

resource "aws_iam_policy_attachment" "iam-attach" {
  name       = "${var.project_name}-iam-attach"
  roles      = [aws_iam_role.main-role.name]
  policy_arn = aws_iam_policy.s3-access.arn
}

resource "aws_iam_instance_profile" "iam-profile" {
  name = "${var.project_name}-iam-profile"
  role = aws_iam_role.main-role.name
}

