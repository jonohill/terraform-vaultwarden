terraform {
  required_providers {
    fly = {
      source = "fly-apps/fly"
    }
  }
}

provider "fly" {
    useinternaltunnel = true
    internaltunnelorg = "personal"
    internaltunnelregion = "syd"
}

variable "smtp_from" {
    type = string
}

module "vaultwarden" {
    source = "./terraform"

    fly_region = "syd"
    env        = {
        SMTP_FROM = var.smtp_from
    }
}
