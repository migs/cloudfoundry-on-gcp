# Cloud Foundry on GCP

THIS IS A WORK IN PROGRESS!

This repo is primarily for my own personal use, but feel free to make use of it.

## Pre-Requisites

1. You have a bosh-bastion set up using [github.com/finkit/bosh-on-gcp](https://www.github.com/finkit/bosh-on-gcp)

## Default Configuration

1. All VMs are configured to be preemptible, so a VM can be destroyed at any given moment. This is for testing purposes, obviously.

## Fresh bosh-bastion steps

```
. ./create-bosh-director.sh
eval `ssh-agent -s`
ssh-add '/home/vagrant/.ssh/id_rsa'
git config --global user.name "Stuart Moore"
git config --global user.email "stuart.moore@gmail.com"
git config --global push.default simple
git clone git@github.com:migs/cloudfoundry-on-gcp.git
cd cloudfoundry-on-gcp/
```

## Create Cloud-Foundry deployment

```
./create-cf.sh
```

## Destroy Cloud-Foundry deployment

This will destroy your whole cloud foundry deployment, and everything within it. Proceed with caution!

You need to enter the project name as an argument, to make sure you are nuking the cprrect project.


```
./destroy-cf.sh projectname
```
