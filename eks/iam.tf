# These are IAM roles and policies needed for EKS Control Plane

data "aws_iam_policy_document" "assumerole-eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-main" {
  name               = "${var.project_name}-eks-main"
  assume_role_policy = data.aws_iam_policy_document.assumerole-eks.json
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  role       = aws_iam_role.eks-main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  role       = aws_iam_role.eks-main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}


# These are IAM roles and policies needed for EKS Nodes

data "aws_iam_policy_document" "assumerole-nodes" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-nodes-main" {
  name               = "${var.project_name}-nodes-main"
  assume_role_policy = data.aws_iam_policy_document.assumerole-nodes.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy-main" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes-main.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy-main" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes-main.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-main" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes-main.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy-main" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks-nodes-main.name
}
