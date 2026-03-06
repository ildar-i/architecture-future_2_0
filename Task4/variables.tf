variable "project_name" {
  description = "Имя проекта, используется в тегах и именах ресурсов"
  type        = string
}

variable "yandex_token" {
  description = "OAuth token для Yandex Cloud (передаётся через переменную окружения TF_VAR_yandex_token или CI/CD secrets)"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "ID облака Yandex Cloud (передаётся через переменную окружения TF_VAR_yandex_cloud_id или CI/CD secrets)"
  type        = string
}

variable "yandex_folder_id" {
  description = "ID каталога Yandex Cloud, где будут созданы ресурсы (передаётся через переменную окружения TF_VAR_yandex_folder_id или CI/CD secrets)"
  type        = string
}

variable "yandex_zone" {
  description = "Зона доступности Yandex Cloud (например, ru-central1-a)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR-блок VPC (не используется напрямую, но оставлен для совместимости)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR-блок публичной подсети"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR-блок приватной подсети"
  type        = string
}

variable "portal_image_id" {
  description = "ID образа для Compute Instance портала самообслуживания (Ubuntu, например fd8kdq6d0p8sij7h5qe3)"
  type        = string
}

variable "portal_platform_id" {
  description = "Платформа для Compute Instance (standard-v1, standard-v2, etc.)"
  type        = string
  default     = "standard-v1"
}

variable "portal_cores" {
  description = "Количество ядер для портала самообслуживания"
  type        = number
  default     = 2
}

variable "portal_memory" {
  description = "Объём памяти (ГБ) для портала самообслуживания"
  type        = number
  default     = 4
}

variable "portal_disk_size" {
  description = "Размер диска (ГБ) для портала самообслуживания"
  type        = number
  default     = 20
}

variable "dwh_allocated_storage" {
  description = "Размер диска (ГБ) для доменного DWH (Managed PostgreSQL)"
  type        = number
}

variable "dwh_instance_class" {
  description = "Класс инстанса для Managed PostgreSQL (s2.micro, s2.small, s2.medium, etc.)"
  type        = string
}

variable "dwh_disk_type" {
  description = "Тип диска для Managed PostgreSQL (network-ssd, network-hdd, local-ssd)"
  type        = string
  default     = "network-ssd"
}

variable "dwh_postgres_version" {
  description = "Версия PostgreSQL для Managed PostgreSQL"
  type        = string
  default     = "14"
}

variable "dwh_username" {
  description = "Имя пользователя БД DWH"
  type        = string
}

variable "dwh_password" {
  description = "Пароль пользователя БД DWH"
  type        = string
  sensitive   = true
}
