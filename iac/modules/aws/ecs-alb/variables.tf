variable "env" {
  type        = string
}

variable "product" {
  type        = string
}

variable "alb_sg" {
  type        = list(string)
}

variable "subnets" {
  type        = list(string)
}

# variable "ssl_certificate_arn" {
#   type        = string
#   default = ""
# }







