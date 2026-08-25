// Bucket for user file uploads (Day 3 multi-modal input).
resource "google_storage_bucket" "uploads" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.name_prefix}-uploads"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = false
  }

  depends_on = [google_project_service.apis]
}
