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


# Checking to see if a repo URL is in the path, if so add it or update.
if [ -z "${HELM_REPOSITORY}" ]; then
    HELM_CHART_NAME=${DEPLOY_CHART_PATH%/*}
    CHART_REPO_EXISTS = $(helm repo list | grep ^${HELM_CHART_NAME})

    if [ -z "${CHART_REPO_EXISTS}" ]; then
        echo "Adding chart"
        helm repo add ${HELM_CHART_NAME} ${HELM_REPOSITORY}
    else
        echo "Updating chart"
        helm repo update ${HELM_CHART_NAME}
    fi
fi

# Upgrade or install the chart.  This does it all.
HELM_COMMAND="helm upgrade --install --timeout ${TIMEOUT}"

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
echo "Executing: ${HELM_COMMAND}"
${HELM_COMMAND}
