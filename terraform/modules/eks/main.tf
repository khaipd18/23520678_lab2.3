module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # Bật OIDC Provider cho cluster
  enable_irsa = true

  # Cấu hình Node Group mặc định
  eks_managed_node_groups = {
    default_node_group = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Cấp quyền admin cho người tạo cluster
  enable_cluster_creator_admin_permissions = true
}