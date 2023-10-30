variable "project_id" {
  type = string
  default = "---YOUR_PROJECT_ID---"
}

variable "project_id_02" {
  type = string
  default = "---YOUR_PROJECT_ID---"
}

variable "prefix" {
  type = string
  description = "A prefix to use for resources created"
  default = "gcp"
}


variable "network1_name" {
  description = "The name of the network being created"
  type        = string
  default = ""
}

variable "network2_name" {
  description = "The name of the network being created"
  type        = string
  default = ""
}

variable "network1_subnet1_name" {
  description = "The subnetwork created in the host network"
  type        = string
}

variable "network1_subnet2_name" {
  description = "The subnetwork created in the host network"
  type        = string
}

variable "network2_subnet1_name" {
  description = "The subnetwork created in the service network"
  type        = string
}

variable "network2_subnet2_name" {
  description = "The subnetwork created in the service network"
  type        = string
}

variable "shared_secret" {
  type = string
  description = "Shared secret for the IPSec tunnel"
}

variable "rules_01" {
  description = "List of custom rule definitions (refer to variables file for syntax)."
  default     = []
  type = list(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    ranges                  = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
    log_config = object({
      metadata = string
    })
  }))
}

# variable "internal_allow" {
#   description = "Allow rules for internal ranges."
#   default = [
#     {
#       protocol = "icmp"
#     },
#   ]
# }

variable "rules_02" {
  description = "List of custom rule definitions (refer to variables file for syntax)."
  default     = []
  type = list(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    ranges                  = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
    log_config = object({
      metadata = string
    })
  }))
}