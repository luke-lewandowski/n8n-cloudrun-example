provider "google" {
  project = var.project_id
  region = var.region
}

terraform {
  backend "gcs" {
    credentials = "./key.json"
    prefix  = "terraform/state"
  }
}

resource "google_cloud_run_service" "hooks" {
  name = "hooks"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/hooks:${var.build_number}"
        resources {
          limits = {
            cpu = "2000m"
            memory = "4096Mi"
          }
        }
        env {
          name = "GOOGLE_PROJECT"
          value = var.project_id
        }
        env {
          name = "REGION"
          value = var.region
        }
        env {
          name = "DB_TYPE"
          value = "postgresdb"
        }
        env {
          name = "DB_INSTANCE"
          value = var.database_instance
        }
        env {
          name = "DB_POSTGRESDB_HOST"
          value = "127.0.0.1"
        }
        env {
          name = "DB_POSTGRESDB_DATABASE"
          value = var.database_name
        }
        env {
          name = "DB_POSTGRESDB_USER"
          value = var.database_user
        }
        env {
          name = "DB_POSTGRESDB_PASSWORD"
          value = var.database_password
        }
        env {
          name = "N8N_ENCRYPTION_KEY"
          value = var.n8n_encryption_key
        }
        env {
          name = "N8N_BASIC_AUTH_ACTIVE"
          value = var.n8n_basic_auth
        }
        env {
          name = "N8N_BASIC_AUTH_USER"
          value = var.n8n_basic_auth_user
        }
        env {
          name = "N8N_BASIC_AUTH_PASSWORD"
          value = var.n8n_basic_auth_password
        }
        env {
          name = "N8N_HOST"
          value = "${var.subdomain}.${var.domain_name}"
        }
        env {
          name = "N8N_PROTOCOL"
          value = "https"
        }
        env {
          name = "EXECUTIONS_PROCESS"
          value = var.n8n_execution_process
        }
        env {
          name = "NODE_ENV"
          value = "production"
        }
        env {
          name = "WEBHOOK_TUNNEL_URL"
          value = "https://${var.subdomain}.${var.domain_name}/"
        }
        env {
          name = "GENERIC_TIMEZONE"
          value = "Etc/GMT"
        }
        env {
          name = "TZ"
          value = "Etc/GMT"
        }
        ports {
          container_port = 5678
        }
      }
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}
resource "google_cloud_run_domain_mapping" "domain" {
  location = var.region
  name     = "${var.subdomain}.${var.domain_name}"

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_service.hooks.name
  }
}

resource "google_dns_record_set" "record" {
  name = "${google_cloud_run_domain_mapping.domain.name}."
  managed_zone = var.zone_name
  ttl  = 300
  type = "CNAME"
  rrdatas = ["ghs.googlehosted.com."]
}

# resource "google_cloud_scheduler_job" "job" {
#   name             = "hooks-${var.environment}-${var.user_locale}"
#   schedule         = var.schedule
#   time_zone        = "Australia/Sydney"
#   attempt_deadline = "900s"

#   http_target {
#     http_method = "POST"
#     uri         = "https://${google_cloud_run_domain_mapping.domain.name}/"
#   }
# }

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.hooks.location
  service = google_cloud_run_service.hooks.name
  project = var.project_id
  policy_data = data.google_iam_policy.noauth.policy_data
}


