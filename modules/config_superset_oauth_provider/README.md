# config_superset_oauth_provider

Terraform module that manages the Superset OAuth providers configuration stored in a Kubernetes `ConfigMap`.

It reads the current `oauth-providers` JSON array from an existing ConfigMap, appends a new provider entry (backed by Keycloak OpenID Connect discovery), and reapplies the updated ConfigMap to the cluster.

---

## What it creates/updates

- **Reads**: `kubernetes_config_map` (data source) for the existing Superset OAuth providers ConfigMap.
- **Applies**: a `kubectl_manifest` containing a Kubernetes `ConfigMap` with:
    - `data["oauth-providers"]` set to a JSON array of providers (previous providers + the new tenant provider).

The module uses templates located in `templates/`:
- `oauth_providers.json` — the provider entry appended to the list.
- `configmap_oauth_poviders.yaml` — the ConfigMap manifest template applied via `kubectl_manifest`.

---

## Provider requirements

This module requires the **kubectl** Terraform provider:

- `alekc/kubectl` `~> 2.1.3`

You must also have access configured so the provider can reach the target Kubernetes cluster.

---

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `tenant` | `string` | n/a | yes | Tenant name. Used in the provider name and to build the Keycloak realm URL. |
| `cluster_domain` | `string` | n/a | yes | Base cluster domain used to build the Keycloak OIDC discovery URL. |
| `superset_namespace` | `string` | `"superset"` | no | Namespace where Superset (and the oauth providers ConfigMap) live. |
| `superset_oauth_providers_configmap_name` | `string` | `"superset-oauth-providers"` | no | Name of the ConfigMap storing OAuth providers under the `oauth-providers` key. |
| `superset_keycloak_client_name` | `string` | `"cosmotech-client-superset"` | no | Keycloak client id used by Superset for this provider. |

---

## Outputs

| Name | Description |
|------|-------------|
| `superset_oauth_providers` | The YAML body applied by `kubectl_manifest` (the ConfigMap manifest containing the updated providers list). |

---

## Behavior and assumptions

- The module **expects** the target ConfigMap to have a key named **`oauth-providers`** containing a JSON array (string).
    - If the key is missing (or the data map is null), it falls back to an empty array (`[]`) and then appends the new provider.
- The Keycloak OIDC discovery URL is constructed as:

  `https://<cluster_domain>/keycloak/realms/<tenant>/.well-known/openid-configuration`

- The resulting ConfigMap is applied with `kubectl_manifest`. This will update the ConfigMap content to include the new provider.

---
## Module files

- `main.tf` — reads current providers, renders templates, applies ConfigMap manifest
- `variables.tf` — module inputs
- `outputs.tf` — module outputs
- `templates/` — YAML/JSON templates used to render the manifest
