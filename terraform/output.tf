output "name" {
  value = local.name
}

output "appurl" {
  value = fly_app.this.url
}
