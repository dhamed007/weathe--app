variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "us-east-2"
}


variable "instance_type" {
  description = "Instance type for EKS worker nodes"
  default     = "t3.medium"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  default     = "my-cluster"
}

variable "node_group_name" {
  description = "Name for the EKS node group"
  default     = "my-node-group"
}

variable "node_group_capacity_type" {
  description = "Capacity type for EKS node group (e.g., ON_DEMAND or SPOT)"
  default     = "ON_DEMAND"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the subnets"
  default     = [ "us-east-2a", "us-east-2b"]
}

variable "eks_cluster_name" {
  description = "Name for the EKS cluster"
  default     = "my-eks-cluster"
}

variable "eks_service_role_arn" {
  description = "ARN of the IAM role for EKS service"
  default     = "arn:aws:iam::123456789012:role/eks-service-role"
}

variable "eks_version" {
  description = "Version of Amazon EKS"
  default     = "1.21"
}