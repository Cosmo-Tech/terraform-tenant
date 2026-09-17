output "redis_secret" {
  value = kubernetes_secret.redis.metadata[0].name
}
