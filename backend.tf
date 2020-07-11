terraform {
 backend "gcs" {
   bucket  = "efk-terraform-admin"
   prefix  = "terraform/state"
 }
}
