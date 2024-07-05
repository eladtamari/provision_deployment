# create VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc-saips-3"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet3"
  region        = "us-east5"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"
}

# # Create Service Account
# resource "google_service_account" "mysa" {
#   account_id   = "mysa"
#   display_name = "Service Account for GKE nodes"
# }


# Create GKE cluster with 2 nodes in our custom VPC/Subnet
resource "google_container_cluster" "primary" {
  name                     = "saips-gke"
  location                 = "us-east5-a"
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true ## create the smallest possible default node pool and immediately delete it.
  # networking_mode          = "VPC_NATIVE" 
  initial_node_count = 1

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.13.0.0/28"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.11.0.0/21"
    services_ipv4_cidr_block = "10.12.0.0/21"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.7/32"
      display_name = "net1"
    }

  }
}

# Create managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = "us-east5-a"
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "dev"
    }

    machine_type = "n2-standard-2"
    preemptible  = true
    #service_account = google_service_account.mysa.email

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}



## Create jump host . We will allow this jump host to access GKE cluster. the ip of this jump host is already authorized to allowin the GKE cluster

resource "google_compute_address" "my_internal_ip_addr" {
  project      = "gke-saips"
  address_type = "INTERNAL"
  region       = "us-east5"
  subnetwork   = "subnet3"
  name         = "my-ip"
  address      = "10.0.0.7"
  description  = "An internal IP address for my jump host"
}


resource "google_compute_image" "default" {
  name = "jump-host"
  project = "gke-saips"
  #family = null  # Specify if the image is part of an image family

  # Specify the source image from GCS
  # raw_disk {
  #   source = "https://storage.cloud.google.com/images_saips/jumpserver_1.tar.gz"
  # }
  #source_image = "https://storage.cloud.google.com/images_saips/jumpserver_1.tar.gz"
  source_image = "images/jumpserver-1"
}
resource "google_compute_instance" "default" {
  project      = "gke-saips"
  zone         = "us-east5-a"
  name         = "jump-host"
  machine_type = "e2-medium"
   
  
  boot_disk {
    initialize_params {
      #image = "ubuntu-os-cloud/ubuntu-2204-lts"
       #image = google_compute_image.default.source_image
       image = google_compute_image.default.name
       
      
    }
  }
  network_interface {
    network    = "vpc-saips-3"
    subnetwork = "subnet3" # Replace with a reference or self link to your subnet, in quotes
    network_ip = google_compute_address.my_internal_ip_addr.address
  }

}


## Creare Firewall to access jump hist via iap


resource "google_compute_firewall" "rules" {
  project = "gke-saips"
  name    = "allow-ssh-3"
  network = "vpc-saips-3" # Replace with a reference or self link to your network, in quotes

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}



## Create IAP SSH permissions for your test instance

resource "google_project_iam_member" "project" {
  project = "gke-saips"
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:gke-service@gke-saips.iam.gserviceaccount.com"
}

# create cloud router for nat gateway
resource "google_compute_router" "router" {
  project = "gke-saips"
  name    = "nat-router-3"
  network = "vpc-saips-3"
  region  = "us-east5"
}

## Create Nat Gateway with module

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id = "gke-saips"
  region     = "us-east5"
  router     = google_compute_router.router.name
  name       = "nat-config"

}


############Output############################################
output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
