# EKS deployments with Helm

GitHub action for deploying to AWS EKS clusters using helm.

## Customizing

### inputs

Following inputs can be used as `step.with` keys

| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws-secret-access-key`          | String  | AWS secret access key part of the aws credentials. This is used to login to EKS. |
| `aws-access-key-id`      | String  | AWS access key id part of the aws credentials. This is used to login to EKS. |
| `aws-region`      | String  | AWS region to use. This must match the region your desired cluster lies in. |
| `cluster-name`      | String  | The name of the desired cluster. |
| `cluster-role-arn`      | String  | If you wish to assume an admin role, provide the role arn here to login as. |
| `config-files`      | String  | Comma separated list of helm values files. |
| `namespace`      | String  | Kubernetes namespace to use.  Will create if it does not exist |
| `values`      | String  | Comma separates list of value set for helms. e.x: key1=value1,key2=value2 |
| `name`      | String  | The name of the helm release |
| `chart-path`      | String  | The path to the chart. (defaults to `helm/`) |


## Example usage

```yaml
uses: ccapell/action-deploy-eks-helm@v1.0.2
with:
  aws-access-key-id: ${{ secrets.AWS_ACCESS__KEY_ID }}
  aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  aws-region: us-west-2
  cluster-name: mycluster
  config-files: .github/values/dev.yaml
  chart-path: chart/
  namespace: dev
  values: key1=value1,key2=value2
  name: release_name
```
