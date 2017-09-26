output "ip" {
    value = "${module.cloud-foundry.ip}"
}

output "tcp_ip" {
    value = "${module.cloud-foundry.tcp_ip}"
}

output "network" {
    value = "${module.cloud-foundry.network}"
}

output "private_subnet" {
    value = "${module.cloud-foundry.private_subnet}"
}

output "compilation_subnet" {
    value = "${module.cloud-foundry.compilation_subnet}"
}

output "zone" {
    value = "${module.cloud-foundry.zone}"
}

output "zone_compilation" {
    value = "${module.cloud-foundry.zone_compilation}"
}

output "region" {
    value = "${module.cloud-foundry.region}"
}

output "region_compilation" {
    value = "${module.cloud-foundry.region_compilation}"
}
