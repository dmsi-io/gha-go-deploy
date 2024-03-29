# GHA Go Deploy

[![release][release-badge]][release]

This GitHub Action encapsulates all of the build and deploy steps required to deploy a Go application to Kubernetes:

- Repository checkout
- Environment Variable exporting
- Go dependency caching/install, test, and build
- Docker containerization
- Kubernetes Deployment

## Inputs

| NAME                    | DESCRIPTION                                                                                      | TYPE     | REQUIRED  | DEFAULT                     |
|-------------------------|--------------------------------------------------------------------------------------------------|----------|-----------|-----------------------------|
| `GCP_IDENTITY_PROVIDER` | GCP Workload Identity Provider.                                                                  | `string` | `true`\*  |                             |
| `GCP_SERVICE_ACCOUNT`   | GCP Service Account email.                                                                       | `string` | `true`\*  |                             |
| `GCP_SA_KEY`            | GCP Service Account Key (JSON).                                                                  | `string` | `true`\*  |                             |
| `GKE_CLUSTER_NAME`      | Google Kubernetes Engine Cluster name.                                                           | `string` | `true`    |                             |
| `GCP_ZONE`              | GCP Zone.                                                                                        | `string` | `true`    |                             |
| `GCP_PROJECT_ID`        | GCP Project ID.                                                                                  | `string` | `true`    |                             |
| `TLD`                   | Top Level Domain to create subdomain on.                                                         | `string` | `true`    |                             |
| `GHA_ACCESS_USER`       | GitHub Actions Access Username. (Required for private Go Modules)                                | `string` | `false`\* |                             |
| `GHA_ACCESS_TOKEN`      | GitHub Actions Access Token. (Required for private Go Modules)                                   | `string` | `false`\* |                             |
| `print_gcloud_info`     | Flag to optionally print gcloud info after authenticating.                                       | `bool`   | `false`   | `false`                     |
| `print_environment`     | Flag to optionally print environment variables.                                                  | `bool`   | `false`   | `false`                     |
| `print_go_env`          | Flag to optionally print go environment.                                                         | `bool`   | `false`   | `false`                     |
| `secret`                | Name of secret to copy from default namespace.                                                   | `string` | `false`   |                             |
| `configmap`             | Filename of configmap config. (Can also be used for any other arbitrary K8S artifact to deploy). | `string` | `false`   | `configmap.yaml`            |
| `skip_k8s_deploy`       | Flag to skip Kubernetes artifact deployment steps.                                               | `bool`   | `false`   | `false`                     |
| `skip_deploy_status`    | Flag to skip deployment status check.                                                            | `bool`   | `false`   | `false`                     |
| `go-version`            | The Go version to download (if necessary) and use. Supports semver spec and ranges.              | `string` | `false`   |                             |
| `skip_cache`            | Flag to skip add dependencies from cache.                                                        | `bool`   | `false`   | `false`                     |
| `skip_install`          | Flag to skip installing dependencies before building.                                            | `bool`   | `false`   | `false`                     |
| `skip_testing`          | Flag to skip running tests.                                                                      | `bool`   | `false`   | `false`                     |
| `test_flags`            | Optional flags to supply to the test step.                                                       | `string` | `false`   |                             |
| `build_flags`           | Optional flags to supply to the build step.                                                      | `string` | `false`   |                             |
| `skip_reset_schema`     | Flag to skip GraphQL schema reset call.                                                          | `bool`   | `false`   | `false`                     |
| `endpoint`              | Endpoint to ping with curl during reset schema step.                                             | `string` | `false`   | `/graphql?resetSchema=true` |

> It is recommended to use Workload Identity Federation with the `GCP_IDENTITY_PROVIDER` and `GCP_SERVICE_ACCOUNT` inputs. `GCP_SA_KEY` will still work with `v1` tags.

## Outputs

| NAME  | DESCRIPTION                                                                                              | TYPE     |
| ----- | -------------------------------------------------------------------------------------------------------- | -------- |
| `url` | The namespace URL generated by the deployment process. Will be an empty string if k8s deploy is skipped. | `string` |

## Example

```yaml
name: Kubernetes Go Deployment
on:
  push:
    branches:
      - develop
      - 'feature/*'

jobs:
  build-deploy:
    name: Build and Deploy Go Service
    runs-on: ubuntu-latest

    permissions:
      contents: 'read'
      id-token: 'write'

    steps:
      - name: Build and Deploy Kubernetes
        uses: dmsi-io/gha-go-deploy@main
        with:
          GCP_IDENTITY_PROVIDER: ${{ secrets.GCP_IDENTITY_PROVIDER }}
          GCP_SERVICE_ACCOUNT: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          GKE_CLUSTER_NAME: ${{ secrets.GCP_STAGING_CLUSTER_NAME }}
          GCP_ZONE: ${{ secrets.GCP_ZONE }}
          GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
          GHA_ACCESS_USER: ${{ secrets.GHA_ACCESS_USER }}
          GHA_ACCESS_TOKEN: ${{ secrets.GHA_ACCESS_TOKEN }}
          TLD: ${{ secrets.TOP_LEVEL_DOMAIN }}
```

> Workload Identity Federation requires access to the id-token permission and thus the outlined permissions in the example above are required.

#### With Service Account Credentials JSON

```yaml
name: Kubernetes Go Deployment
on:
  push:
    branches:
      - develop
      - 'feature/*'

jobs:
  build-deploy:
    name: Build and Deploy Go Service
    runs-on: ubuntu-latest

    permissions:
      contents: 'read'
      id-token: 'write'

    steps:
      - name: Build and Deploy Kubernetes
        uses: dmsi-io/gha-go-deploy@main
        with:
          GCP_SA_KEY: ${{ secrets.GCP_SA_KEY }}
          GKE_CLUSTER_NAME: ${{ secrets.GCP_STAGING_CLUSTER_NAME }}
          GCP_ZONE: ${{ secrets.GCP_ZONE }}
          GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
          GHA_ACCESS_USER: ${{ secrets.GHA_ACCESS_USER }}
          GHA_ACCESS_TOKEN: ${{ secrets.GHA_ACCESS_TOKEN }}
          TLD: ${{ secrets.TOP_LEVEL_DOMAIN }}
```

<!-- badge links -->

[release]: https://github.com/dmsi-io/gha-go-deploy/releases
[release-badge]: https://img.shields.io/github/v/release/dmsi-io/gha-go-deploy?style=for-the-badge&logo=github
