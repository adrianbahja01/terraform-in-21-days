resource "aws_eks_cluster" "eks-main" {
  name     = "${var.project_name}-main"
  role_arn = aws_iam_role.eks-main.arn

  vpc_config {
    subnet_ids = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy
  ]
}

resource "aws_eks_node_group" "eks-nodes-main" {
  cluster_name    = aws_eks_cluster.eks-main.name
  node_group_name = "${var.project_name}-nodes-main"
  node_role_arn   = aws_iam_role.eks-nodes-main.arn
  subnet_ids      = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  depends_on = [
    aws_eks_cluster.eks-main,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-main,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy-main,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy-main,
    aws_iam_role_policy_attachment.CloudWatchAgentServerPolicy-main
  ]
}
