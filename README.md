# terraform-vaultwarden

Experimental terraform module for deploying [Vaultwarden](https://github.com/dani-garcia/vaultwarden) to fly.io, using AWS SES for email.

## Usage

You'll need to set up [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and [Fly](https://registry.terraform.io/providers/fly-apps/fly/latest/docs) on your system so that Terraform can authenticate.

For Vaultwarden itself, [review the available environment variables](https://github.com/dani-garcia/vaultwarden/blob/main/.env.template) and configure for your needs. Some defaults are set to get it working within the Fly environment, but at a minimum set `SMTP_FROM` or Vaultwarden won't start. This should be an email address that you've validated with SES.

See `test.tf` for a very basic example.

## What it deploys

- Fly app, with a machine running Vaultwarden
- SMTP credentials for SES (remember to validate the desired email address)

## Usage notes

Fly machines aren't charged when they're not running, so this module deploys a modified image that exits if no logs have been emitted for a period of time (default 5 minutes). Unless your usage is very high, running this should be dirt cheap. Be sure not to disable logging.
