# Remote state backend.
# NOTE: the bucket referenced here (kuber-jenkins-tfstate-2026-ram) must
# already exist before this backend can be used. Apply the bucket first
# with this block commented out / absent, then add it and run
# `terraform init` to migrate local state into S3.

terraform {
  backend "s3" {
    bucket  = "kuber-jenkins-tfstate-2026-ram"
    key     = "jenkins/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
