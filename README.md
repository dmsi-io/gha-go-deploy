# gha-go-deploy

This GitHub Action encapsulates all of the build and deploy steps required to deploy a Go application to Kubernetes:

- Repository checkout
- Environment Variable exporting
- Go dependency caching/install, test, and build
- Docker containerization
- Kubernetes Deployment

### Usage

```yaml
- name: Build and Deploy Kubernetes
  uses: dmsi-io/gha-go-deploy@v1.2
  with:
    GCP_SA_KEY: ${{ secrets.GCP_SA_KEY }}
    GKE_CLUSTER_NAME: ${{ secrets.GCP_STAGING_CLUSTER_NAME }}
    GCP_ZONE: ${{ secrets.GCP_ZONE }}
    GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
    GHA_ACCESS_USER: ${{ secrets.GHA_ACCESS_USER }}
    GHA_ACCESS_TOKEN: ${{ secrets.GHA_ACCESS_TOKEN }}
    TLD: ${{ secrets.TOP_LEVEL_DOMAIN }}
```

As of v1.1 of this GitHub Action, there will be provided default Kubernetes configuration yaml files. These are the standard for our Go Middleware Services. If a custom configuration is required, those can be supplied in the repository in question under the default folder structure as follows:

![Kubernetes Directory](/assets/k8s_directory.png)

> Only supply the k8s yaml file that requires customization, all others will be copied in from this GitHub Action.

Additionally, the Dockerfile must also be located at the head of the repository.

### Outputs

#### URL

Since this action deploys to a branch specific namespace, this action will output a URL to the namespace.

```yaml
- name: Build and Deploy Kubernetes
  uses: dmsi-io/gha-go-deploy@v1.2
  id: deploy
  with: ...

- name: Print URL
  run: echo ${{ steps.deploy.outputs.url }}
```

### Optional inputs

#### Secret

Used to specify a secret to copy from the default namespace into the namespace being created.

```yaml
with:
  secret: 'secret-env'
```

#### Skip Deployment Status

Sometimes when trying to debug a k8s deployment that refuses to deploy correctly, it can build up a lot of GHA minutes to wait for the timeout of deployment status check. Supplying this flag allows the GHA to skip checking if the deployment was successful.

- Default: `false`

```yaml
with:
  skip_deploy_status: true
```

#### Go Version

Older Go services may require a specific version of Go to be able to compile, this can be supplied via the optional input.

```yaml
with:
  go-version: '^1.13.1' # The Go version to download (if necessary) and use.
```

#### Skip Dependency Caching

By default, this GitHub Action will download and save a cache of the dependencies. This can be skipped with the following optional flag.

- Default: `false`

```yaml
with:
  skip_cache: true
```

#### Skip Dependency Install

By default, this GitHub Action will download and verify dependencies before testing and building. This can be skipped with the following flag.

- Default: `false`

```yaml
with:
  skip_install: true
```

#### Skip Testing

By default, this GitHub Action will run all tests before building. This can be skipped with the following flag.

- Default: `false`

```yaml
with:
  skip_testing: true
```

#### Test Flags

By default, this GitHub Action will run all tests before building. The following input field allows additional flags to be added to the CLI `test` command.

```yaml
with:
  test_flags: '-tags mock' # example, can be any available CLI flags
```

#### Build Flags

The following input field allows additional flags to be added to the CLI `build` command.

```yaml
with:
  build_flags: "-a -ldflags '-w'" # example, can be any available CLI flags
```

#### Skip Resetting GraphQL Schema

Our middleware is powered by a central graphql-api that will pull all available GraphQL schemas when starting up. Additionally, and endpoint is available to manually reset this schema. By default, this action will ping this endpoint in the new namespace to update the GraphQL schema for the repo in question. Providing a `true` value to this input will turn off this behavior if it unnecessary.

- Default: `false`

```yaml
with:
  skip_reset_schema: true
```

#### Endpoint Ping

Traditionally, to reset the GraphQL schema there is a single endpoint that is predefined. However, if a different Go service would like to ping an alternate endpoint in the created namespace, this optional input provides that ability.

- Default: `/graphql?resetSchema=true`

```yaml
with:
  endpoint: '/api/test'
```

#### Print Environment Variables

Sometimes it is helpful to view the environment variables set to help debug. Supplying this flag will print `env | sort` to the console.

- Default: `false`

```yaml
with:
  print_environment: true
```

#### Print GCloud Info

Sometimes it is helpful to view gcloud information to help debug. Supplying this flag will print out `gcloud info` after authenticating.

- Default: `false`

```yaml
with:
  print_gcloud_info: true
```
