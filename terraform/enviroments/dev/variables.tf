variable "env" { 
    type = string 
    default = "dev"
}
variable "cluster_name" { 
    type = string
    default = "lab02-3-cluster"
}
variable "ecr_repos" { 
    type = list(string) 
    default = ["user-service", "product-service"]
}