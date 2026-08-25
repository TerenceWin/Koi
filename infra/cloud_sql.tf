# Generated in Terraform so the password never exists in a file you edit.
# The value lands in Secret Manager (see secret_manager.tf) and in state.
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "main" {
  project          = var.project_id
  name             = "${var.name_prefix}-db"
  region           = var.region
  database_version = "POSTGRES_15"

  settings {
    tier = var.db_tier

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }

  # Flip to true once this holds data you care about.
  deletion_protection = false

  depends_on = [google_project_service.apis]
}

resource "google_sql_database" "app" {
  project  = var.project_id
  name     = "app"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  project  = var.project_id
  name     = "app"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}
