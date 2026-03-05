output "vpc_id" {
  description = "ID созданного VPC"
  value       = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  description = "ID публичной подсети"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "ID приватной подсети"
  value       = yandex_vpc_subnet.private.id
}

output "portal_instance_id" {
  description = "ID Compute Instance портала самообслуживания"
  value       = yandex_compute_instance.portal.id
}

output "portal_public_ip" {
  description = "Публичный IP портала самообслуживания"
  value       = yandex_compute_instance.portal.network_interface[0].nat_ip_address
}

output "dwh_endpoint" {
  description = "Эндпоинт доменного DWH (Managed PostgreSQL)"
  value       = yandex_mdb_postgresql_cluster.dwh.host[0].fqdn
}

output "dwh_port" {
  description = "Порт доменного DWH (Managed PostgreSQL) - стандартный порт PostgreSQL"
  value       = 5432
}

# output "data_lake_bucket" {
#   description = "Имя Object Storage бакета для Data Lake"
#   value       = yandex_storage_bucket.data_lake.bucket
# }
