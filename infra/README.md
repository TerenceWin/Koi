# infra

Terraform definitions for the GCP environment. Everything the app runs on is
declared here — nothing should be created by hand in the console.

## What this provisions

| Resource | Purpose |
| --- | --- |
| 2 × Cloud Run services | `koi-backend` (FastAPI), `koi-frontend` (static React via nginx) |
| Cloud SQL (Postgres 15) | Conversations, users; pgvector later |
| GCS bucket | User file uploads |
| Secret Manager | DB password, Claude API key |
| Artifact Registry | Docker images pushed by CI |
| 3 service accounts | Backend runtime, frontend runtime, CI/CD — each least-privilege |
| Workload Identity Federation | Lets GitHub Actions authenticate without a stored key |

## First-time setup

Both auth steps are required — the second is what the Terraform provider
actually reads:

```bash
gcloud auth login
gcloud auth application-default login
```

Then create your variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Fill in `project_id`. `terraform.tfvars` is gitignored — it never gets committed.

## Usage

```bash
terraform init     # once, and after changing providers
terraform plan     # dry run — always read before applying
terraform apply    # creates real, billed resources
```

## Setting the Claude API key

Terraform creates the secret container but never its contents, so the key
stays out of source control and out of state:

```bash
echo -n "sk-ant-..." | gcloud secrets versions add koi-claude-api-key --data-file=-
```

## After the first apply

`terraform output` prints the values that CI/CD needs. Set these as GitHub
Actions **repository variables** (Settings → Secrets and variables → Actions):

| Repo variable | From output |
| --- | --- |
| `GCP_PROJECT_ID` | your project ID |
| `GCP_REGION` | `asia-northeast1` |
| `GCP_ARTIFACT_REPO` | `artifact_registry_repo` |
| `GCP_WIF_PROVIDER` | `workload_identity_provider` |
| `GCP_CICD_SA_EMAIL` | `cicd_service_account_email` |

## Deliberate shortcuts

These are known tradeoffs, not oversights:

- **Local state.** `terraform.tfstate` lives on one machine. Losing it means
  Terraform forgets what it created. Migrate to a GCS backend when convenient.
- **State contains secrets.** The generated DB password sits in state in
  plaintext — another reason it is gitignored, and a second reason to move to
  a GCS backend with restricted access.
- **Cloud Run is public** (`allUsers` invoker). Fine for a hello world;
  restrict once auth and the user allowlist exist.
- **Wildcard CORS** on the backend, to avoid a URL circular dependency
  between the two services.
- **Placeholder images.** Services boot on Google's public `hello` image
  until CI pushes real ones; `ignore_changes` stops Terraform from reverting
  them afterward.

## Cost note

Cloud Run scales to zero and costs almost nothing idle. **Cloud SQL bills
24/7 regardless of traffic** and is the main ongoing cost here. `terraform
destroy` tears everything down between working sessions if that matters.
