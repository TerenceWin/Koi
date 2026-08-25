output "backend_url" {
  description = "Public URL of the backend Cloud Run service."
  value       = google_cloud_run_v2_service.backend.uri
}

output "frontend_url" {
  description = "Public URL of the frontend Cloud Run service — the app URL."
  value       = google_cloud_run_v2_service.frontend.uri
}

output "artifact_registry_repo" {
  description = "Image path prefix for docker push."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}

output "uploads_bucket" {
  value = google_storage_bucket.uploads.name
}

# --- values to set as GitHub Actions repository variables --------------------

output "cicd_service_account_email" {
  description = "Set as the GCP_CICD_SA_EMAIL repo variable."
  value       = google_service_account.cicd.email
}

output "workload_identity_provider" {
  description = "Set as the GCP_WIF_PROVIDER repo variable."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.main.connection_name
}
