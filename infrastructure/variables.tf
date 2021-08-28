variable "project_id" {
  type = string
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "build_number" {
  type = string
}

variable "database_instance" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_user" {
  type = string
}

variable "database_password" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "n8n_encryption_key" {
  type = string
}

variable "n8n_basic_auth" {
  type = string
}

variable "n8n_basic_auth_user" {
  type = string
}

variable "n8n_basic_auth_password" {
  type = string
}

variable "n8n_execution_process" {
  type = string
}