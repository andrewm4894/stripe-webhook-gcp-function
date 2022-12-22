# rname as conf.tf and update your values, make sure is in .gitignore and does not get commited to github.

variable "gcp_project_id" {
  type    = string
  default = "<your project id>"
}

variable "gcp_project_name" {
  type    = string
  default = "<your project name>"
}

variable "gcp_project_number" {
  type    = string
  default = "<your project number>"
}

variable "stripe_endpoint_secret" {
  type    = string
  default = "<your secret from stripe>"
}
