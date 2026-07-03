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
