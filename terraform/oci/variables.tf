variable "tenancy_ocid" {
  description = "OCID do tenancy — Oracle Cloud Console > Profile > Tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuario — Oracle Cloud Console > Profile > User Settings"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da API key — Oracle Cloud Console > User Settings > API Keys"
  type        = string
}

variable "private_key_path" {
  description = "Caminho local para a chave privada da API key OCI"
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "Regiao Oracle Cloud. sa-saopaulo-1 = Brasil. us-ashburn-1 = US (mais disponibilidade de A1)"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "ssh_public_key" {
  description = "Conteudo da chave SSH publica para acesso a VM (cat ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "warroom_db_user" {
  description = "Usuario do banco PostgreSQL"
  type        = string
  default     = "warroom"
}

variable "warroom_db_password" {
  description = "Senha do banco PostgreSQL"
  type        = string
  sensitive   = true
}

variable "docker_image" {
  description = "Imagem Docker completa com tag (ex: ghcr.io/seu-org/warroom-service:latest)"
  type        = string
}
