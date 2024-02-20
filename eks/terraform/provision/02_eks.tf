resource "aws_iam_role" "empa_eks_cluster_role" {
  name = "empa-eks-cluster"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "eks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "empa-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.empa_eks_cluster_role.name
}

resource "aws_eks_cluster" "empa_eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.empa_eks_cluster_role.arn

  vpc_config {
    subnet_ids = ws_subnet.private_subnets[*].id
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy_attachment.empa-AmazonEKSClusterPolicy]
}
