variable "project_id" {
  type        = string
  description = "GCP project ID (the ID, not the display name)."
}

variable "region" {
  type        = string
  description = "Primary GCP region for all regional resources."
  default     = "us-central1"
}

variable "name_prefix" {
  type        = string
  description = "Short prefix applied to resource names."
  default     = "koi"
}

variable "github_repo" {
  type        = string
  description = "GitHub \"owner/repo\" allowed to assume the CI/CD service account via Workload Identity Federation."
}

variable "backend_image" {
  type        = string
  description = "Backend container image. Defaults to a public placeholder for the first apply, before CI has pushed a real image."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "frontend_image" {
  type        = string
  description = "Frontend container image. Defaults to a public placeholder for the first apply, before CI has pushed a real image."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "db_tier" {
  type        = string
  description = "Cloud SQL machine tier. Shared-core for dev; upsize before real load."
  default     = "db-f1-micro"
}
