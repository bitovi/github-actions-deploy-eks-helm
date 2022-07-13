# EKS deployments with Helm

GitHub action for deploying to AWS EKS clusters using helm.

Note:  If your EKS cluster administrative access is in a private network, you will need to use a self hosted runner in that network to use this action.

## Customizing

### Inputs

Following inputs can be used as `step.with` keys

| Name                    | Type   | Description                                                                                                                                               |
| ----------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws-secret-access-key` | String | AWS secret access key part of the aws credentials. This is used to login to EKS.                                                                          |
| `aws-access-key-id`     | String | AWS access key id part of the aws credentials. This is used to login to EKS.                                                                              |
| `aws-region`            | String | AWS region to use. This must match the region your desired cluster lies in.                                                                               |
| `cluster-name`          | String | The name of the desired cluster.                                                                                                                          |
| `cluster-role-arn`      | String | If you wish to assume an admin role, provide the role arn here to login as.                                                                               |
| `config-files`          | String | Comma separated list of helm values files.                                                                                                                |
| `namespace`             | String | Kubernetes namespace to use.  Will create if it does not exist                                                                                            |
| `values`                | String | Comma separated list of value set for helms. e.x:`key1=value1,key2=value2`                                                                                |
| `name`                  | String | The name of the helm release                                                                                                                              |
| `chart-path`            | String | The path to the chart. (defaults to `helm/`)                                                                                                              |
| `chart-repository`      | String | The URL of the chart-repository (Optional)                                                                                                                |
| `plugins`               | String | Comma separated list of plugins to install. e.x:` https://github.com/hypnoglow/helm-s3.git, https://github.com/someuser/helm-plugin.git` (defaults to none) |
| `timeout`               | String | The value of the timeout for the helm release                                                                                                             |
| `update-deps`           | String | Update chart dependencies                                                                                                                                 |
| `helm-wait`             | String | Add the helm --wait flag to the helm Release (Optional)                                                                                                   |
| `atomic`                | String | Add the helm --atomic flag if set (Optional)                                                                                                              |

## Example usage

```yaml
uses: bitovi/github-actions-deploy-eks-helm@v1.0.3
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

## Example 2
```yaml
    - name: Deploy Helm
      uses: bitovi/github-actions-deploy-eks-helm@v1.0.3
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
        atomic: true
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
