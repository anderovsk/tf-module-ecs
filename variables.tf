variable "region" {
  type        = string
  description = "region"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "name" {
  type        = string
  description = "region"
}


variable "subnet_public_ids" {
  type        = list(string)
  description = "The ids of the public subnet, for the load balancer"
}

variable "subnet_private_ids" {
  type        = list(string)
  description = "The ids of the private subnet, for the containers"
}


# variable "image_url" {
#   type        = string
#   description = "Image name of ECR"
# }

variable "port" {
  type        = number
  description = "Port of application"
}

variable "env" {
  type        = string
  description = "environment"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN"
}


variable "env_variables" {
  type        = string
  description = "Environment Variables for ECS"
}
