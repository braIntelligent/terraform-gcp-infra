# CI/CD Pipeline Setup

## Prerequisites

### 1. Create the remote state bucket

```bash
PROJECT_ID=your-gcp-project-id

gsutil mb -p $PROJECT_ID -l us-central1 gs://${PROJECT_ID}-tfstate
gsutil versioning set on gs://${PROJECT_ID}-tfstate
```

### 2. Configure Workload Identity Federation (no service account keys)

```bash
# Create the service account for the pipeline
gcloud iam service-accounts create github-actions-sa \
  --project=$PROJECT_ID \
  --display-name="GitHub Actions Terraform SA"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

# Create Workload Identity Pool
gcloud iam workload-identity-pools create github-pool \
  --project=$PROJECT_ID \
  --location=global \
  --display-name="GitHub Actions Pool"

# Create the provider
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --project=$PROJECT_ID \
  --location=global \
  --workload-identity-pool=github-pool \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Allow GitHub Actions to impersonate the SA
gcloud iam service-accounts add-iam-policy-binding \
  github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --project=$PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_ORG/terraform-gcp-infra"
```

### 3. Add GitHub Secrets

In your GitHub repo → Settings → Secrets → Actions:

| Secret | Value |
|--------|-------|
| `GCP_PROJECT_ID` | your GCP project ID |
| `WIF_PROVIDER` | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider` |
| `WIF_SERVICE_ACCOUNT` | `github-actions-sa@PROJECT_ID.iam.gserviceaccount.com` |

### 4. Enable production environment approval

GitHub repo → Settings → Environments → New environment → `production`
Add required reviewers — apply won't run until someone approves.

## Pipeline behavior

| Event | CI runs | CD runs |
|-------|---------|---------|
| Open PR | ✅ fmt + validate + plan (comment on PR) | ❌ |
| Push to main | ✅ | ✅ apply (after approval) |
| Push to feature branch | ✅ | ❌ |
