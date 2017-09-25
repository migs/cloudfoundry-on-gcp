#!/usr/bin/env bash

# Terraform variables
network=bosh
project_id=$(gcloud config get-value project 2>/dev/null)
network_project_id=${project_id}
region=$(gcloud config get-value compute/region 2>/dev/null)
region_commpilation=${region}
zone=$(gcloud config get-value compute/zone 2>/dev/null)
zone_compilation=${zone}

#Bosh variables
export service_account="cf-component"
export service_account_email="${service_account}@${project_id}.iam.gserviceaccount.com"

git submodule update -i

cd terraform

terraform get -update=true

if [[ ! -d ".terraform/plugins" ]] | [[ -e "backend.tf" ]]
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


# Set up GCP service account
gcloud iam service-accounts create ${service_account}

if [ ! -f ${service_account_email}.key.json ]; then
    gcloud iam service-accounts keys create ${service_account_email}.key.json --iam-account ${service_account_email}
fi

gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:${service_account_email} \
    --role "roles/editor"
  
gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:${service_account_email} \
    --role "roles/logging.logWriter"
  
gcloud projects add-iam-policy-binding ${project_id} \
    --member serviceAccount:${service_account_email} \
    --role "roles/logging.configWriter"

exit 0 # This point onwards is still WIP !

bosh int \
    --vars-store cf-config/deployment-vars.yml \
    -o cf-release/operations/gcp.yml \
    cf-release/cf-deployment.yml
