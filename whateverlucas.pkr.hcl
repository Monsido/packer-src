packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "test" {
  image = "debian"
  commit = true
}

build {
  sources = ["source.docker.test"]
  hcp_packer_registry {
    bucket_name = "imnot"
  }
  provisioner "shell" {
    inline = [
      "apt-get update && apt-get -y install curl",
      "bash -c \"$(curl -sSL \"https://install.mondoo.com/sh\")\"",
      "cnquery sbom --output cyclonedx-json >/tmp/sbom_cyclonedx.json",
    ]
  }

  provisioner "hcp_sbom" {
    source      = "/tmp/sbom_cyclonedx.json"
    destination = "sbom_cyclonedx.json"
  }
}
