variable "project_name" {
  type        = string
  description = "Project name used for tagging."
  default     = "terraform-workspace-demo"
}

variable "owner" {
  type        = string
  description = "Owner tag."
  default     = "Subhash"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ASG."
  default     = "t3.micro"
}

variable "min_size" {
  type        = number
  description = "Minimum ASG size."
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum ASG size."
  default     = 2
}

variable "desired_capacity" {
  type        = number
  description = "Desired ASG capacity."
  default     = 1
}
