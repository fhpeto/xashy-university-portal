variable "vpc_name" {
    description = "Name of VPC"
    type = string
 default = "xashy-university-portal"
}

variable "region" {
    description="default provider and backend region"
    type = string 
    default =  "us-east-2" 
}