terraform {
  backend "gcs" {
    bucket = "mountain-view-toastmasters-tfstate"
    prefix = "roles-history"
  }
}

locals {
  project_id        = "mountain-view-toastmasters"
  region            = "us-central1"
  app_engine_region = "us-west2"
}

provider "google" {
  project = local.project_id
  region  = local.region
}

data "google_project" "project" {}

resource "google_bigquery_dataset" "mvtm" {
  dataset_id = "mvtm"
  location   = "US"
}

resource "google_storage_bucket" "default" {
  name                        = local.project_id
  location                    = "US"
  uniform_bucket_level_access = true
  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "default-public" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}

resource "google_service_account" "roles-history" {
  account_id   = "roles-history"
  display_name = "Roles history service account"
}

// grant bucket admin access to the service account
resource "google_storage_bucket_iam_member" "storage-admin" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.roles-history.email}"
}

resource "google_project_iam_member" "job-user" {
  project = local.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.roles-history.email}"
}

// grant bigquery editor access
resource "google_bigquery_dataset_iam_member" "bigquery-admin" {
  dataset_id = google_bigquery_dataset.mvtm.dataset_id
  role       = "roles/bigquery.admin"
  member     = "serviceAccount:${google_service_account.roles-history.email}"
}

output "service_account" {
  value = google_service_account.roles-history.email
}

resource "google_app_engine_application" "app" {
  project     = local.project_id
  location_id = local.app_engine_region
}


module "function_usage_logs" {
  source                = "./functions"
  name                  = "bigquery_dump"
  entry_point           = "main"
  available_memory_mb   = 1024
  service_account_email = google_service_account.roles-history.email
  bucket                = google_storage_bucket.default.name
  schedule              = "0 */1 * * *"
  timeout               = 120
  app_engine_region     = local.app_engine_region
}
