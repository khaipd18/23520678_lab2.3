variable "cluster_name" {
  type        = string
  description = "Tên của EKS cluster để gán tag cho VPC"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}