variable "name" {
  description = "Name of the module"
  type        = string
}

variable "entry_point" {
  description = "Name of the entry_point to run"
  type        = string
}

variable "bucket" {
  description = "The export bucket"
  type        = string
}

variable "service_account_email" {
  type = string
}

variable "runtime" {
  description = "The runtime to use"
  type        = string
  default     = "python310"
}

variable "schedule" {
  description = "schedule"
  type        = string
  default     = "0 */1 * * *"
}

variable "available_memory_mb" {
  type    = number
  default = 128
}

variable "timeout" {
  type    = number
  default = 60
}

variable "app_engine_region" {
  type    = string
  default = "us-west2"
}

variable "public" {
  type    = bool
  default = false
}
