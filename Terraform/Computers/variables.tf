variable "vpc_id" {
  type = string
}

variable "app_subnets" {
  type = list(string)
}

variable "sg_alb_id" {
  type = string
}

variable "sg_db_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}
