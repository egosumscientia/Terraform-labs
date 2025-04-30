variable "cluster_name" {
  type    = string
  default = "eks-lab-cluster"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_capacity" {
  type    = number
  default = 2
}
