#!/usr/bin/env bash

# Terraform variables
export network=bosh
export project_id=$(gcloud config get-value project 2>/dev/null)
export network_project_id=${project_id}
export region=$(gcloud config get-value compute/region 2>/dev/null)
export region_compilation=europe-west1
export zone=$(gcloud config get-value compute/zone 2>/dev/null)
export zone_compilation=europe-west1-d

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

erb bosh-google-cpi-release/docs/cloudfoundry/manifest.yml.erb > manifest.yml
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent
bosh upload-release https://storage.googleapis.com/bosh-gcp/beta/stackdriver-tools/latest.tgz -n
bosh upload-release https://bosh.io/d/github.com/cloudfoundry/cf-mysql-release?v=23
bosh upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=0.340.0
bosh upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release?v=43
bosh upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/diego-release?v=0.1463.0
bosh upload-release https://bosh.io/d/github.com/cloudfoundry/cf-release?v=249
bosh upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/cf-routing-release?v=0.142.0
bosh ucc bosh-config/cloud-config.yml -n
bosh urc bosh-config/runtime-config.yml -n
bosh deploy -d cf manifest.yml -n -o cf-config/nano.yml
