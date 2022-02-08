#!/usr/bin/env bash

echo "Logging into kubernetes cluster $CLUSTER_NAME"
if [ -n "$CLUSTER_ROLE_ARN" ]; then
    aws eks \
        --region ${AWS_REGION} \
        update-kubeconfig --name ${CLUSTER_NAME} \
        --role-arn=${CLUSTER_ROLE_ARN}
else
    aws eks \
        --region ${AWS_REGION} \
        update-kubeconfig --name ${CLUSTER_NAME} 
fi


# Check if namespace exists and create it if it doesn't.
if [ -n "$(kubectl get namespaces | grep $DEPLOY_NAMESPACE)" ]; then
    echo "The namespace $DEPLOY_NAMESPACE exists. Skipping creation..."
else
    echo "The namespace $DEPLOY_NAMESPACE does not exists. Creating..."
    kubectl create namespace $DEPLOY_NAMESPACE
fi


echo "Checking for existing deployment"

# Check for existing install.  If not, perform install instead of upgrade
INSTALLED=$(helm list --all -n ${DEPLOY_NAMESPACE} | grep ${DEPLOY_NAME} )

if [ -z $INSTALLED ]; then
    echo "New Install"
    HELM_CHART_NAME=${DEPLOY_CHART_PATH%/*}
    DEPS_UPDATE_COMMAND="helm repo add ${HELM_CHART_NAME} ${HELM_REPOSITORY}"
    HELM_COMMAND="helm install --timeout ${TIMEOUT}"
else
    echo "Upgrade"
    DEPS_UPDATE_COMMAND="helm dependency update ${DEPLOY_CHART_PATH}"
    HELM_COMMAND="helm upgrade --timeout ${TIMEOUT}"
fi
  
# Set paramaters
for config_file in ${DEPLOY_CONFIG_FILES//,/ }
do
    HELM_COMMAND="${HELM_COMMAND} -f ${config_file}"
done
if [ -n "$DEPLOY_NAMESPACE" ]; then
    HELM_COMMAND="${HELM_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi
if [ -n "$DEPLOY_VALUES" ]; then
    HELM_COMMAND="${HELM_COMMAND} --set ${DEPLOY_VALUES}"
fi

# Execute Commands
HELM_COMMAND="${HELM_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH}"
echo "Executing: ${DEPS_UPDATE_COMMAND}"
${DEPS_UPDATE_COMMAND}
echo "Executing: ${HELM_COMMAND}"
${HELM_COMMAND}
