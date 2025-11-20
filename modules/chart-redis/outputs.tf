# output "redis_secret" {
#   value = kubernetes_secret.redis.metadata[0].name
# }

# output "redis_password" {
#   value = kubernetes_secret.redis.data["redis-password"]
# }