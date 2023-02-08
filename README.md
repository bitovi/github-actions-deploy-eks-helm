# EKS deployments with Helm

GitHub action for deploying to AWS EKS clusters using helm.

Note:  If your EKS cluster administrative access is in a private network, you will need to use a self hosted runner in that network to use this action.

## Customizing

### Note on chart repository / oci registry

Although Helm repositories are different than [OCI registries](https://helm.sh/docs/topics/registries/), the `chart-repository` variable supports both options.

See [example below](https://github.com/bitovi/github-actions-deploy-eks-helm#example-3) for reference, but should be similar to using a repo.

### Inputs

Following inputs can be used as `step.with` keys

| Name                       | Type   | Description                                                                                                                                                 |
| -------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws-secret-access-key`    | String | AWS secret access key part of the aws credentials. This is used to login to EKS.                                                                            |
| `aws-access-key-id`        | String | AWS access key id part of the aws credentials. This is used to login to EKS.                                                                                |
| `aws-region`               | String | AWS region to use. This must match the region your desired cluster lies in.                                                                                 |
| `cluster-name`             | String | The name of the desired cluster.                                                                                                                            |
| `cluster-role-arn`         | String | If you wish to assume an admin role, provide the role arn here to login as.                                                                                 |
| `action`                   | String | Determines if we `install` or `uninstall` the chart. (Optional, Defaults to `install`)                                                                      |
| `config-files`             | String | Comma separated list of helm values files.                                                                                                                  |
| `namespace`                | String | Kubernetes namespace to use.  Will create if it does not exist                                                                                              |
| `values`                   | String | Comma separated list of value set for helms. e.x:`key1=value1,key2=value2`                                                                                  |
| `name`                     | String | The name of the helm release                                                                                                                                |
| `chart-path`               | String | The path to the chart. (defaults to `helm/`)                                                                                                                |
| `chart-repository`         | String | The URL of the chart-repository (Optional) Note: If oci based registry, set url to oci://                                                                   |
| `version`                  | String | The version of the chart (Optional)                                                                                                                         |
| `plugins`                  | String | Comma separated list of plugins to install. e.x:` https://github.com/hypnoglow/helm-s3.git, https://github.com/someuser/helm-plugin.git` (defaults to none) |
| `timeout`                  | String | The value of the timeout for the helm release                                                                                                               |
| `update-deps`              | String | Update chart dependencies                                                                                                                                   |
| `helm-wait`                | String | Add the helm --wait flag to the helm Release (Optional)                                                                                                     |
| `atomic`                   | String | Add the helm --atomic flag if set (Optional)                                                                                                                |
| `ca-file`                  | String | Verify certificates of HTTPS-enabled servers using this CA bundle.                                                                                          |
| `cert-file`                | String | Identify HTTPS client using this SSL certificate file.                                                                                                      |
| `key-file`                 | String | Identify HTTPS client using this SSL key file.                                                                                                              |
| `insecure-skip-tls-verify` | String | Skip tls certificate checks for the chart download.                                                                                                         |
| `pass-credentials`         | String | Pass credentials to all domains. set (Optional)                                                                                                             |
| `username`                 | String | Chart repository username where to locate the requested chart.                                                                                              |
| `password`                 | String | Chart repository password where to locate the requested chart.                                                                                              |

## Example 1 - local repo chart

```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.2
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
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        cluster-name: mycluster
        cluster-role-arn: ${{ secrets.AWS_ROLE_ARN }}
        config-files: fluent-bit/prod/values.yaml
        chart-path: fluent/fluent-bit
        namespace: logging
        name: fluent-bit
        chart-repository: https://fluent.github.io/helm-charts
        version: 0.20.6
        atomic: true
```

## Example 3 - OCI Chart Repo
```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.2
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
      uses: aws-actions/configure-aws-credentials@v1
      with:
        role-to-assume: arn:aws:iam::${{ env.aws-account-id }}:role/${{ env.aws-assume-role }}
        aws-region: ${{ env.aws-region }}

    - name: Install Helm Chart
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.2
      with:
        aws-region: ${{ env.aws-region }}
        cluster-name: eks-cluster-${{ env.environment }}
        ... (put your other arguments here)
```

## Example Uninstall

```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.2.2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
        action: uninstall
        cluster-name: mycluster
        namespace: dev
        name: release_name
```

## Contributing
We would love for you to contribute to [`bitovi/github-actions-deploy-eks-helm`](https://github.com/bitovi/github-actions-deploy-eks-helm).   [Issues](https://github.com/bitovi/github-actions-deploy-eks-helm/issues) and [Pull Requests](https://github.com/bitovi/github-actions-deploy-eks-helm/pulls) are welcome!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-eks-helm/blob/main/LICENSE).

## Provided by Bitovi
[Bitovi](https://www.bitovi.com/) is a proud supporter of Open Source software.

## Need help?
Bitovi has consultants that can help.  Drop into [Bitovi's Community Slack](https://www.bitovi.com/community/slack), and talk to us in the `#devops` channel!

Need DevOps Consulting Services?  Head over to [https://www.bitovi.com/devops-consulting](https://hubs.ly/Q01bFvLS0), and book a free consultation.
