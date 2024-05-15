variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "instance_name" {
  type = map(any)
}
variable "master-ports" {
  type = list(number)
}
variable "worker-ports" {
  type = list(number)
}
variable "ports-desc" {
  type = map(any)
}
variable "udp-ports" {
  type = list(number)
}