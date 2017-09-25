terraform {
    backend "gcs" {
        bucket		= "stuart-finkit-blobstore"
        path		= "network/terraform.tfstate"
        project		= "stuart-finkit-cf"
    }
}
