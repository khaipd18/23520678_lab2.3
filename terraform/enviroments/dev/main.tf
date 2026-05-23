
module "vpc" {
  source       = "../../modules/vpc"
  cluster_name = var.cluster_name
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}

module "ecr" {
  source       = "../../modules/ecr"
  repositories = var.ecr_repos
}