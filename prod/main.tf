locals {
  region = "us-central1"
}

terraform {
  cloud {

    organization = "nico-iaco"

    workspaces {
      name = "foody-prod"
    }
  }
}

provider "google" {
  project = "foody-me"
  region  = local.region
}

resource "google_artifact_registry_repository" "foody_ar" {
  cleanup_policy_dry_run = true
  format                 = "DOCKER"
  location               = local.region
  mode                   = "STANDARD_REPOSITORY"
  project                = "foody-me"
  repository_id          = "foody-ar"
}

resource "google_project" "foody_me" {
  auto_create_network = true
  billing_account = var.billing_account
  labels = {
    firebase = "enabled"
  }
  name       = "foody"
  project_id = "foody-me"
}
# terraform import google_project.foody_me projects/foody-me

resource "google_cloud_run_v2_service" "food_details_integrator_be" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = local.region
  name     = "food-details-integrator-be"
  template {
    containers {
      env {
        name  = "REDIS_ENABLED"
        value = "false"
      }
      env {
        name  = "GIN_MODE"
        value = "release"
      }
      env {
        name  = "IS_SANDBOX"
        value = "false"
      }
      env {
        name = "REDIS_URL"
      }
      image = "us-central1-docker.pkg.dev/foody-me/foody-ar/food-details-integrator-be:${var.food_details_integrator_version}"
      ports {
        container_port = 8080
        name           = "http1"
      }
      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }
    }
    max_instance_request_concurrency = 80
    scaling {
      max_instance_count = 3
    }
    service_account = "food-details-integrator-be@foody-me.iam.gserviceaccount.com"
    timeout         = "300s"
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}
# terraform import google_cloud_run_v2_service.food_details_integrator_be projects/foody-me/locations/us-central1/services/food-details-integrator-be

resource "google_cloud_run_v2_service" "food_track_be" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = local.region
  name     = "food-track-be"
  template {
    containers {
      env {
        name  = "GROCERY_BASE_URL"
        value = var.grocery_base_url
      }
      env {
        name  = "GIN_MODE"
        value = "release"
      }
      env {
        name  = "DB_TIMEOUT"
        value = "60"
      }
      env {
        name  = "DSN"
        value = var.food_track_be_dsn
      }
      image = "us-central1-docker.pkg.dev/foody-me/foody-ar/food-track-be:${var.food_track_be_version}"
      name  = "food-track-be-1"
      ports {
        container_port = 8080
        name           = "http1"
      }
      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }
      startup_probe {
        failure_threshold     = 1
        initial_delay_seconds = 0
        period_seconds        = 240
        tcp_socket {
          port = 8080
        }
        timeout_seconds = 240
      }
    }
    max_instance_request_concurrency = 80
    scaling {
      max_instance_count = 10
    }
    service_account = "food-track-be@foody-me.iam.gserviceaccount.com"
    timeout         = "30s"
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}
# terraform import google_cloud_run_v2_service.food_track_be projects/foody-me/locations/us-central1/services/food-track-be

resource "google_cloud_run_v2_service" "grocery_be" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = local.region
  name     = "grocery-be"
  template {
    containers {
      env {
        name  = "SPRING_DATASOURCE_URL"
        value = var.grocery_be_datasource_url
      }
      env {
        name  = "DB_USER"
        value = var.grocery_be_db_user
      }
      env {
        name  = "FOOD_DETAILS_BASE_URL"
        value = var.food_details_base_url
      }
      env {
        name  = "PROJECT_ID"
        value = "foody-me"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = "GROCERY_BE_DB_PASSWORD"
            version = "3"
          }
        }
      }
      image = "us-central1-docker.pkg.dev/foody-me/foody-ar/grocery-be:${var.grocery_be_version}"
      liveness_probe {
        failure_threshold = 3
        http_get {
          path = "/actuator/health"
          port = 8080
        }
        initial_delay_seconds = 10
        period_seconds        = 10
        timeout_seconds       = 1
      }
      name = "grocery-be-1"
      ports {
        container_port = 8080
        name           = "http1"
      }
      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }
      startup_probe {
        failure_threshold = 3
        http_get {
          path = "/actuator/health"
          port = 8080
        }
        initial_delay_seconds = 10
        period_seconds        = 10
        timeout_seconds       = 1
      }
    }
    max_instance_request_concurrency = 80
    scaling {
      max_instance_count = 10
    }
    service_account = "grocery-be@foody-me.iam.gserviceaccount.com"
    timeout         = "30s"
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}
# terraform import google_cloud_run_v2_service.grocery_be projects/foody-me/locations/us-central1/services/grocery-be

resource "google_service_account" "foody-vm-sa" {
  account_id   = "foody-vm-sa"
  display_name = "foody-vm-sa"
  description = "Service account for foody-vm"
}

resource "google_compute_instance_template" "foody_instance_template" {
  name  = "foody-instance-template"
  machine_type = "e2-micro"
  region       = local.region


  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.foody-vm-sa.email
    scopes = ["cloud-platform"]
  }

  // boot disk
  disk {
    auto_delete = true
    boot        = true
    source_image = "debian-cloud/debian-12"
    disk_size_gb = 30
    type         = "pd-standard"
    disk_name   = "foody-disk"
  }

  // networking
  network_interface {
    network = "projects/foody-me/global/networks/foody-net"
    subnetwork = "projects/foody-me/regions/us-central1/subnetworks/foody-subnet"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_from_template" "foody-vm" {
  name = "foody-vm"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.foody_instance_template.self_link_unique

  service_account {
    email = google_service_account.foody-vm-sa.email
    scopes = [ "cloud-platform" ]
  }
}