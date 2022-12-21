########################################
## stripe_webhook
########################################

/*
stripe_webhook
*/

variable "pyfunc_info_stripe_webhook" {
  type = map(string)
  default = {
    name = "stripe_webhook"
    # increment the version string each time you want to force a new deployment
    version = "v4"
  }
}

# zip up our source code
data "archive_file" "pyfunc_zip_stripe_webhook" {
  type        = "zip"
  source_dir  = "../${path.root}/python-functions/${var.pyfunc_info_stripe_webhook.name}/"
  output_path = "../${path.root}/python-functions/zipped/${var.pyfunc_info_stripe_webhook.name}_${var.pyfunc_info_stripe_webhook.version}.zip"
}

# create the storage bucket
resource "google_storage_bucket" "pyfunc_stripe_webhook" {
  name     = "${var.gcp_project_name}_pyfunc_${var.pyfunc_info_stripe_webhook.name}"
  location = var.gcp_location
}

# place the zip-ed code in the bucket
resource "google_storage_bucket_object" "pyfunc_zip_stripe_webhook" {
  name   = "${var.pyfunc_info_stripe_webhook.name}_${var.pyfunc_info_stripe_webhook.version}.zip"
  bucket = google_storage_bucket.pyfunc_stripe_webhook.name
  source = "../${path.root}/python-functions/zipped/${var.pyfunc_info_stripe_webhook.name}_${var.pyfunc_info_stripe_webhook.version}.zip"
}

# define the function resource
resource "google_cloudfunctions_function" "pyfunc_stripe_webhook" {
  name                  = var.pyfunc_info_stripe_webhook.name
  description           = "stripe_webhook"
  source_archive_bucket = google_storage_bucket.pyfunc_stripe_webhook.name
  source_archive_object = google_storage_bucket_object.pyfunc_zip_stripe_webhook.name
  trigger_http          = true
  entry_point           = "stripe_webhook"
  runtime               = "python310"

  secret_environment_variables {
    key     = google_secret_manager_secret.stripe_endpoint_secret.secret_id
    secret  = google_secret_manager_secret.stripe_endpoint_secret.secret_id
    version = google_secret_manager_secret_version.stripe_endpoint_secret.version
  }

}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "pyfunc_iam_invoker_stripe_webhook" {
  project        = google_cloudfunctions_function.pyfunc_stripe_webhook.project
  region         = google_cloudfunctions_function.pyfunc_stripe_webhook.region
  cloud_function = google_cloudfunctions_function.pyfunc_stripe_webhook.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "pyfunc_iam_member_stripe_webhook" {
  for_each       = toset(["roles/secretmanager.viewer", "roles/secretmanager.secretAccessor"])
  project        = google_cloudfunctions_function.pyfunc_stripe_webhook.project
  region         = google_cloudfunctions_function.pyfunc_stripe_webhook.region
  cloud_function = google_cloudfunctions_function.pyfunc_stripe_webhook.name
  role           = each.key
  member         = "serviceAccount:${var.gcp_project_id}@appspot.gserviceaccount.com"
}