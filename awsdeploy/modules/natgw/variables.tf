
variable "vpc_id" {
  description = "ID of the VPC for the NatGW"
  type = number
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to route through the natgw"
  type = list(number)
}

variable "public_subnet_id" {
  description = "Public subnet ID to attach the nagtw to"
  type = number
}

variable "igw_id" {
  description = "Internet GW's ID belonging to the public subnet"
  type = number
}

variable "appname" {
  description = "Application name"
  type = string
}

variable "appname_short" {
  description = "Short application name"
  type = string
}
