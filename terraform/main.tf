terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    fly = {
      source = "fly-apps/fly"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_string" "name_suffix" {
  length  = 7
  special = false
  upper   = false
}

locals {
  has_storage = var.storage_gb > 0
  name        = var.name == "" ? "vaultwarden-${random_string.name_suffix.result}" : var.name
  url         = "https://${fly_app.this.name}.fly.dev"
}

# SES
# ‾‾‾

resource "aws_iam_user" "smtp_user" {
  name = local.name
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "${local.name}_ses_sender"
  description = "Allows sending of emails via SES"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "ses_sender" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "fly_app" "this" {
  name = local.name
}

resource "fly_volume" "this" {
  count = local.has_storage ? 1 : 0

  app    = fly_app.this.name
  name   = "data"
  size   = var.storage_gb
  region = var.fly_region
}

resource "fly_machine" "this" {
  app    = fly_app.this.name
  region = var.fly_region

  image    = "${var.image}:${var.image_tag}"
  cpus     = var.cpus
  memorymb = var.memorymb
  cputype  = var.cputype

  env = merge(
    local.has_storage ? {} : {
      # Disable things that require filesystem writes
      DATA_FOLDER           = "/tmp",
      DATABASE_URL          = "set_me://",
      SENDS_ALLOWED         = "false",
      ICON_SERVICE          = "bitwarden",
      ICON_REDIRECT_CODE    = "301",
      USER_ATTACHMENT_LIMIT = "0",
    },
    {
      RUN_TIMEOUT = var.run_timeout,

      # Default to using system CA certs for Postgres
      PGSSLROOTCERT = "/etc/ssl/certs/ca-certificates.crt",

      # Written to file by startup script
      RSA_KEY     = tls_private_key.rsa_key.private_key_pem,
      RSA_KEY_PUB = tls_private_key.rsa_key.public_key_pem,

      SMTP_HOST     = "email-smtp.${data.aws_region.current.name}.amazonaws.com",
      SMTP_SECURITY = "starttls",
      SMTP_PORT     = "587",
      SMTP_USERNAME = aws_iam_access_key.smtp_user.id,
      SMTP_PASSWORD = aws_iam_access_key.smtp_user.ses_smtp_password_v4,

      DOMAIN = lookup(var.env, "DOMAIN", local.url),
    },
    var.env
  )

  services = [
    {
      internal_port = 80,
      protocol      = "tcp",
      ports = [
        {
          port     = 443
          handlers = ["tls", "http"]
        }
      ]
    }
  ]

  mounts = [
    for v in fly_volume.this : {
      volume = v.id
      path   = "/data"
    }
  ]
}

resource "fly_ip" "this" {
  for_each = toset(["v4", "v6"])

  app  = fly_app.this.name
  type = each.key
}
