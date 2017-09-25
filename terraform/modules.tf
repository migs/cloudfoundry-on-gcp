module "cloud-foundry" {
    source			= "github.com/cloudfoundry-incubator/bosh-google-cpi-release//docs/cloudfoundry"
    project_id			= "${var.project_id}"
    network			= "${var.network}"
    network_project_id		= "${var.network_project_id}"
    region			= "${var.region}"
    region_compilation		= "${var.region_compilation}"
    zone			= "${var.zone}"
    zone_compilation		= "${var.zone_compilation}"
}
