#!/usr/bin/env bash

CF_SYSTEM_DOMAIN="cf.domain.com"
CF_STEMCELL_VERSION=$(grep -A3 stemcells cf-deployment/cf-deployment.yml | grep version | awk -F \" '{print $2}')
CF_DEPLOYMENT_VERSION=v0.27.0

# Terraform variables
export network=bosh
export project_id=$(gcloud config get-value project 2>/dev/null)
export network_project_id=${project_id}
export region=$(gcloud config get-value compute/region 2>/dev/null)
export region_compilation=${region}
#export region_compilation=europe-west1
export zone=$(gcloud config get-value compute/zone 2>/dev/null)
export zone_compilation=${zone}
#export zone_compilation=europe-west1-d

#Bosh variables
export service_account="cf-component"
export service_account_email="${service_account}@${project_id}.iam.gserviceaccount.com"

cd cf-deployment
git checkout master
git pull
git checkout $CF_DEPLOYMENT_VERSION
cd -

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

# Set up GCP service account
if [[ ! $(gcloud iam service-accounts list | grep ${service_account_email}) ]]
then
    gcloud iam service-accounts create ${service_account}
    gcloud projects add-iam-policy-binding ${project_id} --member serviceAccount:${service_account_email} --role "roles/editor"
    gcloud projects add-iam-policy-binding ${project_id} --member serviceAccount:${service_account_email} --role "roles/logging.logWriter"
    gcloud projects add-iam-policy-binding ${project_id} --member serviceAccount:${service_account_email} --role "roles/logging.configWriter"
fi

if [ ! -f ${service_account_email}.key.json ]; then
    gcloud iam service-accounts keys create ${service_account_email}.key.json --iam-account ${service_account_email}
fi

cd ..

bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=${CF_STEMCELL_VERSION}
bosh upload-release https://storage.googleapis.com/bosh-gcp/beta/stackdriver-tools/latest.tgz -n
bosh ucc config/cloud-config.yml -n
bosh urc config/runtime-config.yml -n

bosh int cf-deployment/cf-deployment.yml \
    --vars-store config/cf-deployment-vars.yml \
    --var-errs \
    --var-errs-unused \
    -v system_domain=${CF_SYSTEM_DOMAIN} \
    -o cf-deployment/operations/gcp.yml

bosh -d cf deploy cf-deployment/cf-deployment.yml \
    --vars-store config/cf-deployment-vars.yml \
    -v system_domain=${CF_SYSTEM_DOMAIN} \
    -o cf-deployment/operations/gcp.yml
