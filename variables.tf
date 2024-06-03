variable "vpc_id" {
  type        = string
  description = "VPC to deploy into"
  default     = "vpc-be96ecd9"
}

variable "subnet_id" {
  type    = string
  default = "subnet-91d3c0c9"
}

variable "subnet_b_id" {
  type    = string
  default = "subnet-i82d7c9bf"
}