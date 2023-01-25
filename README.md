# terraform-vaultwarden

# Work in progress
## This doesn't do anything useful yet

Experimental terraform module for deploying [Vaultwarden](https://github.com/dani-garcia/vaultwarden) to fly.io, using AWS SES for email.

## What it deploys

- Fly machine running Vaultwarden
- SMTP credentials for SES (remember to validate the desired email address)

## Usage notes

Fly machines aren't charged when they're not running, so this module deploys a modified image that exits if no logs have been emitted for a period of time (default 5 minutes). Unless your usage is very high, running this should be dirt cheap. Be sure not to disable logging.
