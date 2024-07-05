terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.8.0"
    }
  }
}


provider "google" {
  region      = "us-east5"
  project     = "gke-saips"
  credentials = file("gke-saips-e899c86916c9.json")
  zone        = "us-east5-a"

}
