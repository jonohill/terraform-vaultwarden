variable "name" {
  default     = ""
  description = "Name to use for resources, must be globally unique. If unset a unique name will be generated prefixed with 'vaultwarden-'."
}

variable "run_timeout" {
  default     = 300
  description = "Amount of time app runs before sleeping"
}

variable "env" {
  type = map(string)
}

variable "image" {
  default = "ghcr.io/jonohill/terraform-vaultwarden"
}

variable "image_tag" {
  default = "1.27.0"
}

variable "storage_gb" {
  default     = 1
  description = "Can be set to 0 to disable storage. If so, you'll need to use an external database."
}

variable "fly_region" {
  type    = string
}

variable "cpus" {
  default = 1
}

variable "memorymb" {
  default = 256
}

variable "cputype" {
  default = "shared"
}
