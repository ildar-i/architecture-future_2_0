terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100.0"
    }
  }
}

provider "yandex" {
  zone = var.yandex_zone
}

# VPC Network
resource "yandex_vpc_network" "main" {
  name = "${var.project_name}-vpc"
}

# Public Subnet
resource "yandex_vpc_subnet" "public" {
  name           = "${var.project_name}-public-subnet"
  zone           = var.yandex_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# NAT Gateway для приватной подсети
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.project_name}-nat-gw"
  shared_egress_gateway {}
}

# Route Table для приватной подсети через NAT Gateway
resource "yandex_vpc_route_table" "private" {
  name       = "${var.project_name}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Private Subnet с NAT Gateway
resource "yandex_vpc_subnet" "private" {
  name           = "${var.project_name}-private-subnet"
  zone           = var.yandex_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.private.id
}

# Security Group для портала самообслуживания
resource "yandex_vpc_security_group" "portal_sg" {
  name        = "${var.project_name}-portal-sg"
  description = "Security group for self-service data portal"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  labels = {
    name = "${var.project_name}-portal-sg"
  }
}

# Security Group для сервисов данных (DWH, orchestrator)
resource "yandex_vpc_security_group" "data_sg" {
  name        = "${var.project_name}-data-sg"
  description = "Security group for data services (DWH, orchestrator)"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description       = "PostgreSQL from portal"
    protocol          = "TCP"
    port              = 5432
    security_group_id = yandex_vpc_security_group.portal_sg.id
  }

  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  labels = {
    name = "${var.project_name}-data-sg"
  }
}

# Compute Instance для портала самообслуживания
resource "yandex_compute_instance" "portal" {
  name        = "${var.project_name}-portal"
  platform_id = var.portal_platform_id
  zone        = var.yandex_zone

  resources {
    cores  = var.portal_cores
    memory = var.portal_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.portal_image_id
      size     = var.portal_disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.portal_sg.id]
    nat                = true
  }

  labels = {
    name = "${var.project_name}-portal-ec2"
    role = "self-service-portal"
  }
}

# Managed PostgreSQL для доменного DWH
resource "yandex_mdb_postgresql_cluster" "dwh" {
  name        = "${var.project_name}-dwh"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.main.id

  config {
    version = var.dwh_postgres_version
    resources {
      resource_preset_id = var.dwh_instance_class
      disk_size          = var.dwh_allocated_storage
      disk_type_id       = var.dwh_disk_type
    }
  }

  database {
    name  = "dwh"
    owner = var.dwh_username
  }

  user {
    name     = var.dwh_username
    password = var.dwh_password
  }

  host {
    zone             = var.yandex_zone
    subnet_id        = yandex_vpc_subnet.private.id
    assign_public_ip = false
  }

  security_group_ids = [yandex_vpc_security_group.data_sg.id]

  deletion_protection = false

  labels = {
    name = "${var.project_name}-dwh"
    role = "domain-dwh"
  }
}

# Object Storage Bucket для Data Lake
# ВНИМАНИЕ: Для работы с Object Storage через Terraform нужны AWS-совместимые credentials
# Получите их в консоли Yandex Cloud: Service Accounts -> Static Access Keys
# Затем экспортируйте: export AWS_ACCESS_KEY_ID=... и export AWS_SECRET_ACCESS_KEY=...
# 
# После настройки credentials раскомментируйте этот блок:
#
# resource "yandex_storage_bucket" "data_lake" {
#   bucket = "${var.project_name}-data-lake"
#   acl    = "private"
#
#   versioning {
#     enabled = true
#   }
# }
