# EKS control plane. AWS runs the API server, scheduler, and etcd across AZs; we
# provide the network and IAM. The OIDC provider below lets Kubernetes service
# accounts assume IAM roles (IRSA) without static credentials — used by the
# Cluster Autoscaler (see iam.tf).

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.cluster_log_types

  tags = {
    Name      = local.cluster_name
    Component = local.component
  }

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

# OIDC provider for IRSA. The thumbprint is read from the cluster's OIDC issuer.
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name      = "${local.cluster_name}-oidc"
    Component = local.component
  }
}
