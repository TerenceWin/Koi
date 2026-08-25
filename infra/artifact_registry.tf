resource "google_artifact_registry_repository" "images" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.name_prefix}-images"
  format        = "DOCKER"
  description   = "Container images for the backend + frontend Cloud Run services."

  depends_on = [google_project_service.apis]
}
