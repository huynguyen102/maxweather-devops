variable "project" {
  description = "Project name; first segment of every resource name and the Project tag."
  type        = string
  default     = "maxweather"
}

variable "environment" {
  description = "Infrastructure environment (e.g. prod); second segment of resource names. App staging/prod are Kubernetes namespaces, not separate infra."
  type        = string
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread the network across (>= 2 for HA)."
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets (cheaper) instead of one per AZ (more available)."
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.31"
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
  description = "Minimum number of nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes."
  type        = number
  default     = 4
}

variable "eks_endpoint_public_access" {
  description = "Expose the Kubernetes API endpoint publicly (needed for kubectl/CI from outside the VPC)."
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Narrow this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
