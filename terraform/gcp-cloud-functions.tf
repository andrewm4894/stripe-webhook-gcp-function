########################################
## stripe_webhook
########################################

/*
stripe_webhook function to recieve a webhook event from stripe, validate its signature is as expected, and just print the event.
*/

# increment the version string each time you want to force a new deployment since this 
# will trigger a new archive and force code update of the function.
variable "pyfunc_info_stripe_webhook" {
  type = map(string)
  default = {
    name        = "stripe_webhook"
    description = "stripe_webhook"
    version     = "v20"
    runtime     = "python310"
  }
}

# create service account to run the function
resource "google_service_account" "pyfunc_stripe_webhook" {
  account_id   = replace(var.pyfunc_info_stripe_webhook.name, "_", "-")
  display_name = var.pyfunc_info_stripe_webhook.name
}

# zip up our source code into a local folder that will be uploaded to a GCS bucket
data "archive_file" "pyfunc_stripe_webhook" {
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
resource "google_storage_bucket_object" "pyfunc_stripe_webhook" {
  name   = "${var.pyfunc_info_stripe_webhook.name}_${var.pyfunc_info_stripe_webhook.version}.zip"
  bucket = google_storage_bucket.pyfunc_stripe_webhook.name
  source = data.archive_file.pyfunc_stripe_webhook.output_path
}

# create the function
resource "google_cloudfunctions_function" "pyfunc_stripe_webhook" {
  name        = var.pyfunc_info_stripe_webhook.name
  description = var.pyfunc_info_stripe_webhook.description

  # tell the function where the code for it lives in GCS
  source_archive_bucket = google_storage_bucket.pyfunc_stripe_webhook.name
  source_archive_object = google_storage_bucket_object.pyfunc_stripe_webhook.name

  # this is a http function as opposed to a pubsub one
  trigger_http = true

  # entry point is the function name within your main.py to call
  entry_point = var.pyfunc_info_stripe_webhook.name
  runtime     = var.pyfunc_info_stripe_webhook.runtime

  # run this function with a specific service account
  service_account_email = google_service_account.pyfunc_stripe_webhook.email

  # make secret available as env var to the function
  secret_environment_variables {
    key     = google_secret_manager_secret.stripe_endpoint_secret.secret_id
    secret  = google_secret_manager_secret.stripe_endpoint_secret.secret_id
    version = google_secret_manager_secret_version.stripe_endpoint_secret.version
  }

}

# IAM entry for all users to invoke the function.
# This makes it publicly executable.
resource "google_cloudfunctions_function_iam_member" "pyfunc_stripe_webhook" {
  project        = google_cloudfunctions_function.pyfunc_stripe_webhook.project
  region         = google_cloudfunctions_function.pyfunc_stripe_webhook.region
  cloud_function = google_cloudfunctions_function.pyfunc_stripe_webhook.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
