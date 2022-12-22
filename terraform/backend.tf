# remote backend for terraform state.
# will need to manually create this bucket before running `terraform init`.
# bucket name needs to be unique across all of gcp.
terraform {
  backend "gcs" {
    bucket = "andrewm4894-stripe-webhook-gcp-function-tf-state"
    prefix = "terraform/state"
  }
}