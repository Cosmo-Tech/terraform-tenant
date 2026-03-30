# chart_cosmotech_api

Terraform module that deploys the **Cosmo Tech API** Helm chart into a tenant namespace.

This module installs the `cosmotech-api` chart from the Cosmo Tech Helm repository and injects the tenant-specific configuration required to connect the API to:

- **Keycloak** for authentication
- **PostgreSQL** for data storage
- **Redis** for resource storage
- **S3-compatible object storage**
- **Harbor / container registry**
- **Argo Workflows** for workflow orchestration

---

## What this module does

The module:

- Reads required credentials from existing Kubernetes secrets in the tenant namespace
- Builds a values file from `values.yaml`
- Deploys the Helm chart `cosmotech-api`
- Exposes the API through ingress on the cluster domain
- Enables monitoring through a `ServiceMonitor`

---

## Requirements

This module assumes the following is already available:

- A working Kubernetes cluster
- Terraform with Kubernetes and Helm providers configured
- A tenant namespace already created
- Required dependencies already deployed and configured:
    - Keycloak
    - PostgreSQL
    - Redis
    - S3-compatible storage
    - Harbor-compatible registry
    - Argo Workflows
- The required Kubernetes secrets already exist in the tenant namespace

---

## Helm chart

This module deploys:

- **Repository**: `https://cosmo-tech.github.io/helm-charts`
- **Chart**: `cosmotech-api`
- **Version**: `5.0.0`

---

## Expected Kubernetes secrets

The module reads the following existing secrets:

### `redis`
In namespace `${tenant}`

Expected key:
- `redis-password`

### S3 secret
Secret name comes from input variable `s3_secret`.

Expected keys:
- value of `s3_secret_key_username`
- value of `s3_secret_key_password`

### `keycloak-cosmotech-client-api`
In namespace `${tenant}`

Used as an existing dependency for the tenant API client configuration.

### `harbor`
In namespace `${tenant}`

Expected keys:
- `username`
- `password`

---

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `tenant` | `string` | n/a | yes | Tenant namespace and tenant identifier. |
| `release` | `string` | n/a | yes | Helm release prefix used to name the deployment. |
| `postgresql_host` | `string` | n/a | yes | PostgreSQL host used by the API. |
| `postgresql_port` | `string` | n/a | yes | PostgreSQL port. |
| `postgresql_database` | `string` | n/a | yes | PostgreSQL database name used by the API. |
| `postgresql_admin_username` | `string` | n/a | yes | PostgreSQL admin username. |
| `postgresql_admin_password` | `string` | n/a | yes | PostgreSQL admin password. |
| `postgresql_writer_username` | `string` | n/a | yes | PostgreSQL writer username. |
| `postgresql_writer_password` | `string` | n/a | yes | PostgreSQL writer password. |
| `postgresql_reader_username` | `string` | n/a | yes | PostgreSQL reader username. |
| `postgresql_reader_password` | `string` | n/a | yes | PostgreSQL reader password. |
| `s3_host` | `string` | n/a | yes | S3-compatible storage host. |
| `s3_port` | `string` | n/a | yes | S3-compatible storage port. |
| `s3_bucket` | `string` | n/a | yes | Bucket used by the API. |
| `s3_secret` | `string` | n/a | yes | Name of the Kubernetes secret containing S3 credentials. |
| `s3_secret_key_username` | `string` | n/a | yes | Key name in the S3 secret containing the access key / username. |
| `s3_secret_key_password` | `string` | n/a | yes | Key name in the S3 secret containing the secret key / password. |
| `cluster_domain` | `string` | n/a | yes | Base cluster domain used for ingress and Keycloak URLs. |
| `keycloak_client_id` | `string` | n/a | yes | Keycloak client id used by the API. |
| `keycloak_client_secret` | `string` | n/a | yes | Keycloak client secret used by the API. |
| `cosmotech_api_connect_timeout` | `string` | `"30s"` | no | NGINX ingress connect timeout. |
| `cosmotech_api_query_timeout` | `string` | `"60s"` | no | NGINX ingress read/send timeout. |
| `cosmotech_api_buffer_size` | `string` | `"16K"` | no | NGINX client body buffer size. |
| `cosmotech_api_max_file_size` | `string` | `"300m"` | no | Maximum request / upload body size. |

---

## Ingress behavior

Ingress is enabled by default and configured with:

- TLS secret: `letsencrypt-prod-${tenant}`
- Ingress class: `nginx`
- Cert-manager cluster issuer: `letsencrypt-prod-${tenant}`

The API is exposed on the cluster domain and uses the configured timeout and request size values.

---

## Notes

- This module does **not** create the tenant namespace.
- This module does **not** create PostgreSQL, Redis, S3 storage, Harbor, Argo-Workflows or Keycloak resources.
- It assumes all dependencies and secrets already exist before deployment.

---

## Module files

- `main.tf` — Helm release and Kubernetes secret lookups
- `variables.tf` — module input variables
- `values.yaml` — Helm values template used for deployment

---

## Troubleshooting

### Secret not found
If Terraform fails while reading a Kubernetes secret, verify that:

- the secret exists in namespace `${tenant}`
- the secret name matches the expected value
- the expected keys exist in the secret data

### Helm release fails
If the Helm release does not install successfully, check:

- chart repository accessibility
- Kubernetes / Helm provider authentication
- dependency services availability
- values rendered from the module inputs

### API ingress issues
If the API is unreachable:

- Verify DNS for `cluster_domain`
- Check ingress controller status
- Verify cert-manager issuer and generated TLS secret
- Inspect ingress annotations and timeouts

If the API is slow or fails:
- If you observe 504/499 errors on long queries, increase `cosmotech_api_query_timeout`.
- If you see `413 Request Entity Too Large`, increase `cosmotech_api_max_file_size`.
- If uploads fail with buffering-related errors, increase `cosmotech_api_buffer_size`.


---
## Maintainers

Cosmo Tech DevOps / platform engineering team.