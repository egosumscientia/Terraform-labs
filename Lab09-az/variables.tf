variable "resource_group_name" {
  default = "rg-aks-lab"
}

variable "location" {
  default = "East US"
}

variable "aks_cluster_name" {
  default = "aks-lab-cluster"
}

variable "node_count" {
  default = 2
}