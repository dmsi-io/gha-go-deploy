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
  uses: dmsi-io/gha-go-deploy@v1.1
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

- Default: `false`

```yaml
  with:
    test_flags: '-tags mock' # example, can be any available CLI flags
```

#### Build Flags

The following input field allows additional flags to be added to the CLI `build` command.

- Default: `false`

```yaml
  with:
    build_flags: "-a -ldflags '-w'" # example, can be any available CLI flags
```