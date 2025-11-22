variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use."
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags."
}
