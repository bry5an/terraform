variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-east-1"
}
variable "office_ip" {}
variable "vpn_ip" {}
variable "build_vpc_id" {}
variable "build_owner_id" {}

variable "web_ips" {
  default = {
    "0" = "10.10.0.100"
    "1" = "10.10.0.101"
    "2" = "10.10.0.102"
    "3" = "10.10.0.103"
    "4" = "10.10.0.104"
    "5" = "10.10.0.105"
    "6" = "10.10.0.106"
    "7" = "10.10.0.107"
    "8" = "10.10.0.108"
    "9" = "10.10.0.109"
  }
}

variable "db_ips" {
  default = {
    "0" = "10.10.0.200"
    "1" = "10.10.0.201"
    "2" = "10.10.0.202"
    "3" = "10.10.0.203"
    "4" = "10.10.0.204"
    "5" = "10.10.0.205"
    "6" = "10.10.0.206"
    "7" = "10.10.0.207"
    "8" = "10.10.0.208"
    "9" = "10.10.0.209"
  }
}