# Remote state: shared, encrypted, locked. The bucket + lock table are created by
# terraform/bootstrap (run once). Another AWS account changes the bucket name to
# match its own bootstrap output.
terraform {
  backend "s3" {
    bucket         = "maxweather-tfstate-905418181527"
    key            = "maxweather/prod/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "maxweather-tflock"
    encrypt        = true
  }
}
