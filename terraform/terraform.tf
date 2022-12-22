terraform {
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.46.0"
    }
  }

  backend "gcs" {
    bucket = "andrewm4894-stripe-webhook-gcp-function-tf-state"
    prefix = "terraform/state"
  }

}

provider "google" {
  credentials = file(var.gcp_terraform_service_account_json_path)
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}
