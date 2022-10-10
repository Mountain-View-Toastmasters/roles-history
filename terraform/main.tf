terraform {
  backend "gcs" {
    bucket = "mountain-view-toastmasters-tfstate"
    prefix = "roles-history"
  }
}

locals {
  project_id = "mountain-view-toastmasters"
  region     = "us-central1"
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

resource "google_service_account" "roles-history" {
  account_id   = "roles-history"
  display_name = "Roles history service account"
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
