output "eks_cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "eks_cluster_security_group_ids" {
  value = aws_eks_cluster.my_cluster.vpc_config[0].security_group_ids
}

output "eks_cluster_subnet_ids" {
  value = aws_eks_cluster.my_cluster.vpc_config[0].subnet_ids
}

output "eks_cluster_role_arn" {
  value = aws_eks_cluster.my_cluster.role_arn
}