## Fresh bosh-bastion steps

```
eval `ssh-agent -s`
'/home/vagrant/.ssh/id_rsa'
. ./create-bosh-director.sh
git clone git@github.com:migs/cloudfoundry-on-gcp.git
cd cloudfoundry-on-gcp/
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent
bosh upload-release https://storage.googleapis.com/bosh-gcp/beta/stackdriver-tools/latest.tgz -n
bosh ucc bosh-config/cloud-config.yml -n
bosh urc bosh-config/runtime-config.yml -n
```
