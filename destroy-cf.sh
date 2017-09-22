#!/usr/bin/env bash

cd bosh-google-cpi-release/docs/cloudfoundry

network=bosh
project_id=$(gcloud config get-value project 2>/dev/null)
network_project_id=${project_id}
region=$(gcloud config get-value compute/region 2>/dev/null)
region_commpilation=${region}
zone=$(gcloud config get-value compute/zone 2>/dev/null)
zone_compilation=${zone}

if [[ ! -d ".terraform/plugins" ]]
then
    terraform init
fi

terraform delete \
  -var network=${network} \
  -var project_id=${project_id} \
  -var network_project_id=${network_project_id} \
  -var region=${region} \
  -var region_compilation=${region_compilation} \
  -var zone=${zone} \
  -var zone_compilation=${zone_compilation}

gcloud iam service-accounts create cf-component

gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:cf-component@${project_id}.iam.gserviceaccount.com \
    --role "roles/editor"
  
gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:cf-component@${project_id}.iam.gserviceaccount.com \
    --role "roles/logging.logWriter"
  
gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:cf-component@${project_id}.iam.gserviceaccount.com \
    --role "roles/logging.configWriter"

export vip=$(terraform output ip)
export tcp_vip=$(terraform output tcp_ip)
export zone=$(terraform output zone)
export zone_compilation=$(terraform output zone_compilation)
export region=$(terraform output region)
export region_compilation=$(terraform output region_compilation)
export private_subnet=$(terraform output private_subnet)
export compilation_subnet=$(terraform output compilation_subnet)
export network=$(terraform output network)
export director=$(bosh env | sed -n 2p)
