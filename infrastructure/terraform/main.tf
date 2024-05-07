# AWS provider
provider "aws" {
  region = var.aws_region
}

# Create IAM role for Amazon EKS
resource "aws_iam_role" "eks_admin_role" {
  name = "eks-admin-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": ["eks.amazonaws.com", "ec2.amazonaws.com"]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}
  
  # Attach AdministratorAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_admin_role_attachment" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}





# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my-vpc"
  }
}

# Create public subnet


resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zone[0]  # First availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone[1]  # Second availability zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create Route Table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public_subnet1 with public_route_table
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate public_subnet2 with public_route_table
resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.my_vpc.id

  # Define ingress rules (allow inbound traffic)
  ingress {
    from_port   = 443  # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere (update as needed)
  }

  # Define egress rules (allow outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to anywhere (update as needed)
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

# Create EKS cluster in the public subnet
resource "aws_eks_cluster" "my_cluster" {
  name    = var.eks_cluster_name
  role_arn = aws_iam_role.eks_admin_role.arn


  vpc_config {
    subnet_ids        = [
      aws_subnet.public_subnet1.id,
      aws_subnet.public_subnet2.id
    ]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]  # Use the ID of the created security group
  }

  tags = {
    Name = "my-eks-cluster"
  }
}

# Create EKS node group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_admin_role.arn
  subnet_ids      = [aws_subnet.public_subnet1.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_eks_cluster.my_cluster,
  ]
}