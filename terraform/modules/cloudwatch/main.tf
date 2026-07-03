# Centralized logging (requirement #6). The amazon-cloudwatch-observability addon
# runs Fluent Bit + the CloudWatch agent on every node; Fluent Bit tails each
# container's stdout and ships it to CloudWatch Logs. The app itself needs no AWS
# credentials — it just writes JSON to stdout (see app/app.py).

locals {
  component = "observability"

  insights_log_groups = [
    "/aws/containerinsights/${var.cluster_name}/application",
    "/aws/containerinsights/${var.cluster_name}/dataplane",
    "/aws/containerinsights/${var.cluster_name}/host",
    "/aws/containerinsights/${var.cluster_name}/performance",
  ]
}

# The agent runs on the nodes and assumes the node role, so that role needs
# permission to publish logs and metrics.
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = var.node_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Pre-create the log groups so retention is bounded (otherwise the addon creates
# them with never-expire, and logs — and cost — grow without limit).
resource "aws_cloudwatch_log_group" "insights" {
  for_each = toset(local.insights_log_groups)

  name              = each.value
  retention_in_days = var.log_retention_days

  tags = {
    Name      = each.value
    Component = local.component
  }
}

resource "aws_eks_addon" "observability" {
  cluster_name                = var.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Component = local.component
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent,
    aws_cloudwatch_log_group.insights,
  ]
}
