terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "GCP Zone where the SAP VM is running"
  type        = string
  default     = "europe-west3-a"
}

variable "network_name" {
  description = "VPC network name created by SAP CAL"
  type        = string
}

variable "allowed_source_ranges" {
  description = "CIDR ranges allowed to access Fiori Launchpad"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vm_ip" {
  description = "External IP of the SAP VM"
  type        = string
}

variable "ssh_user" {
  description = "SSH user with sudo privileges on the SAP VM"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Firewall rule allowing HTTP 8000 and HTTPS 8001 for SAP Fiori Launchpad
resource "google_compute_firewall" "allow_sap_fiori_8000" {
  name        = "allow-sap-fiori-8000-cal"
  network     = var.network_name
  project     = var.project_id
  description = "Allow HTTP port 8000 and HTTPS port 8001 for SAP Fiori Launchpad"

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["8000", "8001"]
  }

  source_ranges = var.allowed_source_ranges
}

# Configure HTTP 8000 and HTTPS 8001 ports in SAP instance profile and restart R3
resource "terraform_data" "sap_icm_http_https" {
  depends_on = [google_compute_firewall.allow_sap_fiori_8000]

  connection {
    type  = "ssh"
    host  = var.vm_ip
    user  = var.ssh_user
    agent = true
    }

  provisioner "remote-exec" {
    inline = [
      # Ensure HTTP port 8000 is configured
      "sudo su - abaadm -c \"grep -q 'PORT=8000' /sapmnt/ABA/profile/ABA_D00_vhcalabaci || echo 'icm/server_port_0 = PROT=HTTP,PORT=8000,TIMEOUT=60,PROCTIMEOUT=60' >> /sapmnt/ABA/profile/ABA_D00_vhcalabaci\"",
      # Ensure HTTPS port 8001 is configured
      "sudo su - abaadm -c \"grep -q 'PORT=8001' /sapmnt/ABA/profile/ABA_D00_vhcalabaci || echo 'icm/server_port_1 = PROT=HTTPS,PORT=8001,TIMEOUT=60,PROCTIMEOUT=60' >> /sapmnt/ABA/profile/ABA_D00_vhcalabaci\"",
      # Restart SAP R3 instance
      "sudo su - abaadm -c 'stopsap r3 && startsap r3'"
    ]
  }
}