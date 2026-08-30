resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.name_prefix}-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

# Terraform owns this secret's *existence*, not its real contents. Set the
# real value out-of-band so the key never touches source control:
#   echo -n "sk-ant-..." | gcloud secrets versions add koi-claude-api-key --data-file=-
resource "google_secret_manager_secret" "claude_api_key" {
  project   = var.project_id
  secret_id = "${var.name_prefix}-claude-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

# Cloud Run mounts this secret at version "latest", which fails to resolve if
# the secret has no versions at all. This placeholder makes a cold `terraform
# apply` succeed without a manual pre-step. Adding the real key later creates
# a NEWER version, which "latest" then resolves to — and ignore_changes stops
# Terraform from ever reverting it.
resource "google_secret_manager_secret_version" "claude_api_key_placeholder" {
  secret      = google_secret_manager_secret.claude_api_key.id
  secret_data = "placeholder-set-real-key-via-gcloud"

  lifecycle {
    ignore_changes = [secret_data]
  }
}

locals {
  backend_secrets = {
    db_password    = google_secret_manager_secret.db_password.secret_id
    claude_api_key = google_secret_manager_secret.claude_api_key.secret_id
  }
}

# Read access granted per-secret, not project-wide.
resource "google_secret_manager_secret_iam_member" "backend_secret_access" {
  for_each = local.backend_secrets

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_run.email}"
}
