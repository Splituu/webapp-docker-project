variable "project" {
  description = "Prefiks nazwy projektu dla wszystkich zasobów w AWS"
  type        = string
  default     = "demo-webapp"
}

variable "region" {
  description = "Region AWS do deploymentu"
  type        = string
  default     = "eu-central-1"
}
