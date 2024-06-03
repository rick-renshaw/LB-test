variable "vpd_id" {
  type        = string
  description = "VPC to deploy into"
  default     = "vpc-07068304fe34bf54a"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0ef49ff008bf44f9f"
}

variable "subnet_b_id" {
  type    = string
  default = "subnet-03f20d8e5f100c4cf"
}