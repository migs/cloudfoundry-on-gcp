# Cloud Foundry on GCP

THIS IS A WORK IN PROGRESS!

## Pre-Requisites

1. You have a bosh-bastion set up using [github.com/finkit/bosh-on-gcp](https://www.github.com/finkit/bosh-on-gcp)

## Fresh bosh-bastion steps

```
eval `ssh-agent -s`
ssh-add '/home/vagrant/.ssh/id_rsa'
. ./create-bosh-director.sh
git clone git@github.com:migs/cloudfoundry-on-gcp.git
cd cloudfoundry-on-gcp/
```

## Create Cloud-Foundry deployment

```
./create-cf.sh
```

## Destroy Cloud-Foundry deployment

This will destroy your whole cloud foundry deployment, and everything within it. Proceed with caution!


```
./destroy-cf.sh
```
