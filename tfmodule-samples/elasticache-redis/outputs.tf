output "cluster_id" {
  value       = module.redis.cluster_id
  description = "Redis cluster ID"
}

output "cluster_arn" {
  value       = module.redis.cluster_arn
  description = "Elasticache Replication Group ARN"
}

output "cluster_enabled" {
  value       = module.redis.cluster_enabled
  description = "Indicates if cluster mode is enabled"
}

output "engine_version_actual" {
  value       = module.redis.engine_version_actual
  description = "The running version of the cache engine"
}

output "cluster_endpoint" {
  value       = module.redis.endpoint
  description = "Redis primary endpoint"
}

output "cluster_reader_endpoint" {
  value       = module.redis.reader_endpoint
  description = "Redis non-cluster reader endpoint"
}
