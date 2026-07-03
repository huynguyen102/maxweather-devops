variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the control-plane ENIs and the node group."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes (floor for Cluster Autoscaler)."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes (ceiling for Cluster Autoscaler)."
  type        = number
  default     = 4
}

variable "node_capacity_type" {
  description = "ON_DEMAND for stable capacity, or SPOT for cheaper interruptible capacity."
  type        = string
  default     = "ON_DEMAND"
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API endpoint publicly (needed for kubectl/CI from outside the VPC)."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Narrow this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "Control-plane log types shipped to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}
