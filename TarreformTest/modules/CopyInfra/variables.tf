variable "PM_USER" {
  type    = string
  default = "default-value"
}

variable "PM_PASS" {
  type    = string
  default = "default-value"
  sensitive = true
}

variable "PM_USER2" {
  type    = string
  default = "default-value"
}

variable "PM_PASS2" {
  type    = string
  default = "default-value"
  sensitive = true
}

variable "InternalRouter" {
  type    = string 
}

variable "DNS" {
  type    = string 
}

variable "FTPSSH" {
  type    = string 
}

variable "Database" {
  type    = string 
}

variable "Web" {
  type    = string 
}

variable "IntIPSCHEME" {
  type    = string 
}

variable "ExtIPSCHEME" {
  type    = string 
}

variable "IntBridge" {
  type    = string 
}

variable "ExtBridge" {
  type    = string 
}

variable "Pool" {
  type    = string 
}

variable "DNS_id" {
  type    = string 
}


variable "Web_id" {
  type    = string 
}


variable "Database_id" {
  type    = string 
}


variable "InternalRouter_id" {
  type    = string 
}


variable "FTPSSH_id" {
  type    = string 
}

variable "hackathon_ip" {
  type    = string 
}

variable "hackathon_interface" {
  type    = string 
}


variable "InternalRouterExt_ip" {
  type    = string 
}


variable "dst_address" {
  type    = string 
}

variable "net_id" {
  type    = string 
}

variable "hackathon_id" {
  type    = string 
}














