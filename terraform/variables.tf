# some default variables used in defining resources

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "gcp_location" {
  type    = string
  default = "US"
}

variable "gcp_zone" {
  type    = string
  default = "us-east1-a"
}

# path to the service account credentials you want to run terraform as
variable "gcp_terraform_service_account_json_path" {
  type    = string
  default = "C:/Users/andre/Documents/tmp/my-svc-account.json"
}
