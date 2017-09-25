variable "project_id" {
    type = "string"
}

variable "network" {
    type = "string"
    default = "bosh"
}

variable "network_project_id" {
    type = "string"
}

variable "region" {
    type = "string"
    default = "europe-west2"
}

variable "region_compilation" {
    type = "string"
    default = "europe-west2"
}

variable "zone" {
    type = "string"
    default = "europe-west2-a"
}

variable "zone_compilation" {
    type = "string"
    default = "europe-west2-a"
}
