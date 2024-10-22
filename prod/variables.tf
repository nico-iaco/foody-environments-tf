# variables.tf

variable "redis_url" {
  description = "Redis URL"
  type        = string
  default = ""
}

variable "grocery_be_datasource_url" {
  description = "Grocery-be datasource URL"
  type        = string
  default     = ""
}

variable "grocery_be_db_user" {
  description = "Database user"
  type        = string
  default     = ""
}

variable "food_details_base_url" {
  description = "Food details base URL"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "Project ID"
  type        = string
  default     = "foody-me"
}


variable "grocery_base_url" {
  description = "Grocery base URL"
  type        = string
  default     = ""
}

variable "food_track_be_dsn" {
  description = "Food track be DSN"
  type        = string
  default     = ""
}

variable "food_details_integrator_version" {
  description = "Food details integrator version"
  type        = string
  default     = ""
}

variable "food_track_be_version" {
  description = "Food track be version"
  type        = string
  default     = ""
}

variable "grocery_be_version" {
  description = "Grocery be version"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "Billing account"
  type        = string
  default     = ""
}