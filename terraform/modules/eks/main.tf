module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.35"

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

  access_entries = {
    jenkins_ci_access = {
      principal_arn     = "arn:aws:iam::797226340543:user/jenkins-ci"
      
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}