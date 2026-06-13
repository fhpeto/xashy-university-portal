variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "xashy-university-portal"
}

variable "region" {
  description = "default provider and backend region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "SDLC environment"
  type        = string
  default     = "dev"

}

variable "project" {
  description = "name of the project"
  default     = "xashy-uni-portal"
}