# Remote state backend — obligatorio para CI/CD
# El pipeline necesita un estado compartido entre runners
# Crear el bucket antes del primer terraform init:
#   gsutil mb -p YOUR_PROJECT_ID -l us-central1 gs://YOUR_PROJECT_ID-tfstate
#   gsutil versioning set on gs://YOUR_PROJECT_ID-tfstate

terraform {
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-tfstate"
    prefix = "terraform/dev"
  }
}
