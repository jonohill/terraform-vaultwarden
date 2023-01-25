variable "name" {
  default     = ""
  description = "Name to use for resources, must be globally unique. If unset a unique name will be generated prefixed with 'vaultwarden-'."
}

varialbe "run_timeout" {
  default     = 600
  description = "Amount of time app runs before sleeping"
}

variable "env" {
  type = map(string)
}

variable "image" {
  default = "ghcr.io/jonohill/vaultwarden:1.27.0"
}

variable "storage_gb" {
  default     = 1
  description = "Can be set to 0 to disable storage. If so, you'll need to use an external database."
}

variable "fly_region" {
  type    = string
  default = "syd"
}

variable "cpus" {
  default = 1
}

variable "memorymb" {
  default = 256
}
