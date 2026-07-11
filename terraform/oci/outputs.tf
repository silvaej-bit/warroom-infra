output "vm_public_ip" {
  description = "IP publico da VM — salve como secret OCI_VM_IP no GitHub Actions"
  value       = oci_core_instance.warroom.public_ip
}

output "ssh_command" {
  description = "Comando para acessar a VM via SSH"
  value       = "ssh ubuntu@${oci_core_instance.warroom.public_ip}"
}

output "api_url" {
  description = "URL da API REST"
  value       = "http://${oci_core_instance.warroom.public_ip}:8080/api/v1/ocorrencias"
}

output "swagger_url" {
  description = "URL do Swagger UI"
  value       = "http://${oci_core_instance.warroom.public_ip}:8080/swagger-ui.html"
}
