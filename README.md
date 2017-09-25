## Fresh bosh-bastion steps

```
. ./create-bosh-director.sh
git clone git@github.com:migs/cloudfoundry-on-gcp.git
cd cloudfoundry-on-gcp/
git submodules update -i
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent
bosh upload-release https://storage.googleapis.com/bosh-gcp/beta/stackdriver-tools/latest.tgz -n
bosh ucc bosh-scripts/cloud-configs/gcp/europe-west2.yml -n
bosh urc bosh-scripts/runtime-config.yml -n
```
