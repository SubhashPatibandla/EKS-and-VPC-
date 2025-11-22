terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  environment = terraform.workspace

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    Owner       = var.owner
  }
}

module "network" {
  source = "./modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)

  environment = local.environment
  common_tags = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  environment = local.environment
  common_tags = local.common_tags
}

output "alb_dns_name" {
  description = "Public ALB DNS name"
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  value = module.network.vpc_id
}
