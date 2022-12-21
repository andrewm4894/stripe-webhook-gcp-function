########################################
## stripe_endpoint_secret
########################################

resource "google_secret_manager_secret" "stripe_endpoint_secret" {
  secret_id = "stripe_endpoint_secret"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "stripe_endpoint_secret" {
  secret      = google_secret_manager_secret.stripe_endpoint_secret.id
  secret_data = var.stripe_endpoint_secret
}

resource "google_secret_manager_secret_iam_binding" "stripe_endpoint_secret" {
  for_each  = toset(["roles/secretmanager.viewer", "roles/secretmanager.secretAccessor"])
  project   = var.gcp_project_number
  secret_id = "projects/${var.gcp_project_number}/secrets/${google_secret_manager_secret.stripe_endpoint_secret.secret_id}"
  role      = each.key
  members   = ["serviceAccount:${var.gcp_project_id}@appspot.gserviceaccount.com"]
}
