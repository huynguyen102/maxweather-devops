# Core EKS addons. Versions are left to the EKS default for the cluster version,
# so they stay compatible on upgrade. coredns needs schedulable nodes, so all
# addons wait for the node group.

resource "aws_eks_addon" "core" {
  for_each = toset(["vpc-cni", "kube-proxy", "coredns"])

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Component = local.component
  }

  depends_on = [aws_eks_node_group.default]
}
