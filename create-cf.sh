#!/usr/bin/env bash

network=bosh
project_id=$(gcloud config get-value project 2>/dev/null)
network_project_id=${project_id}
region=$(gcloud config get-value compute/region 2>/dev/null)
region_commpilation=${region}
zone=$(gcloud config get-value compute/zone 2>/dev/null)
zone_compilation=${zone}

cd terraform

terraform get -update=true

if [[ ! -d ".terraform/plugins" ]]
then
    terraform init
fi

terraform plan \
  -var network=${network} \
  -var project_id=${project_id} \
  -var network_project_id=${network_project_id} \
  -var region=${region} \
  -var region_compilation=${region_compilation} \
  -var zone=${zone} \
  -var zone_compilation=${zone_compilation}

terraform apply \
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
