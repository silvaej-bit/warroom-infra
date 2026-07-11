# VM.Standard.A1.Flex — ARM64, 2 OCPU + 12 GB RAM, sempre gratuito
# Free Tier total: ate 4 OCPU + 24 GB entre todas as instancias A1
resource "oci_core_instance" "warroom" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "warroom-service"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.main.id
    assign_public_ip = true
    display_name     = "warroom-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      db_user     = var.warroom_db_user
      db_password = var.warroom_db_password
      image_name  = var.docker_image
    }))
  }
}
