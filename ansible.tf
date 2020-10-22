
//variable "keystore_password" {
//  description = "Password to keystore"
//  type        = string
//}
//
//variable "keystore_path" {
//  description = "Path to keystore"
//  type        = string
//}

//variable "pokt_username" {
//
//}
//variable "pokt_group" {}
variable "domain_name" {}
variable "hostname" {}
variable "force_create" {
  default = true
}
variable "certbot_admin_email" {
  default = ""
}
variable "playbook_vars" {
  type    = map(string)
  default = {}
}

module "ansible" {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0"
  create = var.create

  force_create = var.force_create

  ip               = join("", aws_eip_association.this.*.public_ip)
  user             = "ubuntu"
  private_key_path = var.private_key_path

  playbook_file_path = "${path.module}/ansible/main.yml"
  playbook_vars = merge({
    //    pokt_username = var.pokt_username
    //    pokt_group = var.pokt_group
    enable_pokt_nginx = var.domain_name != "" && var.hostname != ""
    enable_pokt_ssl   = var.domain_name != "" && var.hostname != ""

    fqdn = join(".", concat([var.hostname, var.domain_name]))

    certbot_admin_email = var.certbot_admin_email == "" ? "admin@${var.domain_name}" : var.certbot_admin_email
  }, var.playbook_vars)

  requirements_file_path = "${path.module}/ansible/requirements.yml"
}

