#!/usr/bin/env bash

# Login to Kubernetes Cluster.
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
if [ -n "$(kubectl get namespaces | grep $NAMESPACE)" ]; then
    echo "The namespace $NAMESPACE exists. Skipping creation..."
else
    echo "The namespace $NAMESPACE does not exists. Creating..."
    kubectl create namespace $NAMESPACE
fi


# Helm Deployment
if [ -n "$HELM_REPOSITORY" ]; then
   HELM_CHART_NAME=${DEPLOY_CHART_PATH%/*}
   DEPS_UPDATE_COMMAND="helm repo add ${HELM_CHART_NAME} ${HELM_REPOSITORY}"
else
   DEPS_UPDATE_COMMAND="helm dependency update ${DEPLOY_CHART_PATH}"
fi

# Check for existing install.  If not, perform install instead of upgrade
INSTALLED=$(helm list --all -n ${DEPLOY_NAMESPACE} | grep ${DEPLOY_NAME} )

if [ -z $INSTALLED ]; then
    HELM_COMMAND="helm install --timeout ${TIMEOUT}"
else
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