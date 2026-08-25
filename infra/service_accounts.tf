# Runtime identity for the backend Cloud Run service.
resource "google_service_account" "backend_run" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-backend-run"
  display_name = "Backend Cloud Run runtime SA"
}

# Runtime identity for the frontend Cloud Run service. Serves static files
# only, so it gets no project permissions at all.
resource "google_service_account" "frontend_run" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-frontend-run"
  display_name = "Frontend Cloud Run runtime SA"
}

# Identity assumed by GitHub Actions via Workload Identity Federation to
# build/push images and deploy revisions. No long-lived JSON key exists.
resource "google_service_account" "cicd" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-cicd"
  display_name = "GitHub Actions CI/CD SA"
}

# --- backend runtime permissions --------------------------------------------

resource "google_project_iam_member" "backend_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_run.email}"
}

# Scoped to this one bucket rather than a project-wide storage role.
resource "google_storage_bucket_iam_member" "backend_bucket_access" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend_run.email}"
}

# --- CI/CD permissions -------------------------------------------------------

resource "google_project_iam_member" "cicd_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_project_iam_member" "cicd_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

# Required for CI/CD to deploy revisions that *run as* the runtime SAs.
resource "google_service_account_iam_member" "cicd_actas_backend" {
  service_account_id = google_service_account.backend_run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cicd.email}"
}

resource "google_service_account_iam_member" "cicd_actas_frontend" {
  service_account_id = google_service_account.frontend_run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cicd.email}"
}
