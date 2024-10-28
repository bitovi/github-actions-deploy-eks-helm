# Deploy Helm charts to AWS EKS cluster

`bitovi/github-actions-deploy-eks-helm` deploys helm charts to an EKS Cluster.
![alt](https://bitovi-gha-pixel-tracker-deployment-main.bitovi-sandbox.com/pixel/LW06qgz37wS0e62G4UHYS)
## Action Summary
This action deploys Helm charts to an EKS cluster, allowing ECR/OCI as sources, and handling plugin installation, using [this awesome Docker image](https://github.com/alpine-docker/k8s) as base.

> **Note:** If your EKS cluster administrative access is in a private network, you will need to use a self hosted runner in that network to use this action.

If you would like to deploy a backend app/service, check out our other actions:
| Action | Purpose |
| ------ | ------- |
| [Deploy Docker to EC2](https://github.com/marketplace/actions/deploy-docker-to-aws-ec2) | Deploys a repo with a Dockerized application to a virtual machine (EC2) on AWS |
| [Deploy React to GitHub Pages](https://github.com/marketplace/actions/deploy-react-to-github-pages) | Builds and deploys a React application to GitHub Pages. |
| [Deploy static site to AWS (S3/CDN/R53)](https://github.com/marketplace/actions/deploy-static-site-to-aws-s3-cdn-r53) | Hosts a static site in AWS S3 with CloudFront |
<br/>

**And more!** Check our [list of actions in the GitHub marketplace](https://github.com/marketplace?category=&type=actions&verification=&query=bitovi).

# Need help or have questions?
This project is supported by [Bitovi, A DevOps consultancy](https://www.bitovi.com/services/devops-consulting).

You can **get help or ask questions** on our [Discord Community](https://discord.gg/zAHn4JBVcX).


## Customizing

> **Note:** Although Helm repositories are different than [OCI registries](https://helm.sh/docs/topics/registries/), the `chart-repository` variable supports both options.

See [example below](https://github.com/bitovi/github-actions-deploy-eks-helm#example-3) for reference, but the process should be similar to using a repo.

### Note on charts list command

You can use the name as a way to filter results, or just leave it blank to get all the charts available. 

### Inputs

The following inputs are available as `step.with` keys:

| Name                       | Type   | Description                                                                                                                                                 |
| -------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws-secret-access-key`    | String | AWS secret access key part of the aws credentials. This is used to login to EKS.                                                                            |
| `aws-access-key-id`        | String | AWS access key id part of the aws credentials. This is used to login to EKS.                                                                                |
| `aws-region`               | String | AWS region to use. This must match the region your desired cluster is in.                                                                                   |
| `cluster-name`             | String | The name of the desired cluster.                                                                                                                            |
| `cluster-role-arn`         | String | If you wish to assume an admin role, provide the role arn here to log in as.                                                                                |
| `action`                   | String | Determines if we `install`/`uninstall` the chart, or `list`. (Optional, Defaults to `install`)                                                              |
| `dry-run`                  | Boolean | Toggles `dry-run` option for `install`/`uninstall` action. (Defaults to `false`)                                                                           |
| `config-files`             | String | Comma separated list of helm values files.                                                                                                                  |
| `namespace`                | String | Kubernetes namespace to use.  To create the namespace if it doesn't exist, also set `create-namespace` to `true`.    |
| `create-namespace`         | Boolean | Adds `--create-namespace` when set to `true`. Requires cluster API permissions. (Default: `true`)                   |
| `values`                   | String | Comma separated list of value set for helms. e.x: `key1=value1, key2=value2`                                                                                |
| `name`                     | String | The name of the helm release.                                                                                                                               |
| `chart-path`               | String | The path to the chart. (defaults to `helm/`)                                                                                                                |
| `chart-repository`         | String | The URL of the chart-repository (Optional) Note: If oci based registry, set url to oci://                                                                   |
| `version`                  | String | The version of the chart (Optional)                                                                                                                         |
| `plugins`                  | String | Comma separated list of plugins to install. e.x:` https://github.com/hypnoglow/helm-s3.git, https://github.com/someuser/helm-plugin.git` (defaults to none) |
| `timeout`                  | String | The value of the timeout for the helm release.                                                                                                              |
| `update-deps`              | Boolean | Update chart dependencies                                                                                                                                  |
| `helm-wait`                | String | Add the helm --wait flag to the helm Release (Optional)                                                                                                     |
| `atomic`                   | String | Add the helm --atomic flag if set (Optional)                                                                                                                |
| `ca-file`                  | String | Verify certificates of HTTPS-enabled servers using this CA bundle.                                                                                          |
| `cert-file`                | String | Identify HTTPS client using this SSL certificate file.                                                                                                      |
| `key-file`                 | String | Identify HTTPS client using this SSL key file.                                                                                                              |
| `insecure-skip-tls-verify` | String | Skip tls certificate checks for the chart download.                                                                                                         |
| `pass-credentials`         | String | Pass credentials to all domains. set (Optional)                                                                                                             |
| `username`                 | String | Chart repository username where to locate the requested chart.                                                                                              |
| `password`                 | String | Chart repository password where to locate the requested chart.                                                                                              |
| `use-secrets-vals`         | Boolean | Use secrets plugin using vals to evaluate the secrets                                                                                                      |
| `helm-extra-args`          | String | Append any string containing any extra option that might escape the ones present in this action.                                       

## Example 1 - local repo chart

```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        cluster-name: mycluster
        config-files: .github/values/dev.yaml
        chart-path: chart/
        namespace: dev
        values: key1=value1,key2=value2
        name: release_name
```

## Example 2 - Custom Chart Repo
```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        cluster-name: mycluster
        cluster-role-arn: ${{ secrets.AWS_ROLE_ARN }}
        config-files: fluent-bit/prod/values.yaml
        chart-path: fluent/fluent-bit
        namespace: logging
        create-namespace: true
        name: fluent-bit
        chart-repository: https://fluent.github.io/helm-charts
        version: 0.20.6
        atomic: true
```

## Example 3 - OCI Chart Repo
```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        cluster-name: mycluster
        cluster-role-arn: ${{ secrets.AWS_ROLE_ARN }}
        chart-repository: oci://registry.io/
        chart-path: organization/chart
        namespace: org
        name: some-name
        version: 0.1.0
```

## Example 4 - Separate AWS login
```yaml
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        role-to-assume: arn:aws:iam::${{ env.aws-account-id }}:role/${{ env.aws-assume-role }}
        aws-region: ${{ env.aws-region }}

    - name: Install Helm Chart
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-region: ${{ env.aws-region }}
        cluster-name: eks-cluster-${{ env.environment }}
        ... (put your other arguments here)
```

## Example 5 - Use secrets with vals backend
```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        cluster-name: mycluster
        config-files: .github/values/dev.yaml
        chart-path: chart/
        namespace: dev
        values: key1=value1,key2=value2
        name: release_name
        use-secrets-vals: true
        plugins: https://github.com/jkroepke/helm-secrets
```

## Example 6 - Define multiple values

```yaml
    - name: Install Karpenter
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ vars.AWS_REGION }}
        cluster-name: ${{ vars.CLUSTER_NAME }}
        cluster-role-arn: ${{ secrets.AWS_ROLE_ARN }}
        chart-repository: oci://public.ecr.aws
        chart-path: karpenter/karpenter
        helm-wait: true
        namespace: karpenter
        name: karpenter
        values: |
          settings.clusterName=${{ vars.CLUSTER_NAME }},
          settings.interruptionQueue=${{ vars.CLUSTER_NAME }}-karpenter,
          controller.resources.requests.cpu=1,
          controller.resources.requests.memory=1Gi,
          controller.resources.limits.cpu=1,
          controller.resources.limits.memory=1Gi
        version: 1.0.6
```

## Example 7 - Use with S3 as repo
```yaml
    - name: Deploy S3 Helm chart
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        chart-repository: s3://my-s3-bucket/
        chart-path: my-service/my-service
        version: 0.1.0
        cluster-name: mycluster
        namespace: dev
        name: my_service_name
        plugins: https://github.com/hypnoglow/helm-s3.git
```
* See the [official AWS Guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-a-helm-v3-chart-repository-in-amazon-s3.html) on how to set this up.

## Example 8 - Use a different role in the Action than the role the cluster was built with

**action.yaml**
```yaml
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        role-to-assume: arn:aws:iam::${{ env.aws-account-id }}:role/${{ env.aws-assume-role }}
        aws-region: ${{ env.aws-region }}
    - name: Install Helm Chart
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-region: ${{ env.aws-region }}
        cluster-name: eks-cluster-${{ env.environment }}
        ... (put your other arguments here)
```

**terraform.tf**
```yaml
    ... (surrounding code)

    module "eks" {
      source  = "terraform-aws-modules/eks/aws"
      version = "~> 20.11.1"

    ... (surrounding code)

        access_entries = {
            kubernetes_groups = []
            principal_arn     = var.aws-assume-role.role_arn
        
            policy_associations = {
              access_entry_policy = {
                policy_arn = var.aws-assume-role.aws_policy_arn
                access_scope = {
                  type       = "cluster"
                }
              }
            }
        }
    }

    ... (surrounding code)
```

> NOTE: If you see an error like `Not Authorized` or `Kubernetes cluster unreachable: the server has asked for the client to provide credentials`, it could be due to this Action using a different role than the EKS cluster was built with. The previous fix was to add an entry to the `aws-auth` ConfigMap in the `kube-system` namespace; however, AWS is now using [Access Entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html) which might need to be adjusted to give the Action Role access to the EKS cluster.  
> You may be able to use to an [AssumedRole](https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#assumerole-with-role-previously-assumed-by-action-in-same-workflow) method where you chain the roles together in the AWS authentication instead.

## Example Uninstall

```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        action: uninstall
        cluster-name: mycluster
        namespace: dev
        name: release_name
```

## Example List

```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.11
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        action: list
        namespace: dev
        name: release_name
```

## Contributing
We would love for you to contribute to [`bitovi/github-actions-deploy-eks-helm`](https://github.com/bitovi/github-actions-deploy-eks-helm).   [Issues](https://github.com/bitovi/github-actions-deploy-eks-helm/issues) and [Pull Requests](https://github.com/bitovi/github-actions-deploy-eks-helm/pulls) are welcome!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-eks-helm/blob/main/LICENSE).

## Provided by Bitovi
[Bitovi](https://www.bitovi.com/) is a proud supporter of Open Source software.

## Need help or have questions?
You can **get help or ask questions** on [Discord channel](https://discord.gg/zAHn4JBVcX)! Come hang out with us!

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/devops-consulting).
