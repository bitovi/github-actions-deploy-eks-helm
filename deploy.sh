#!/usr/bin/env bash
set -euo pipefail

# catch exit 1 (which is a special case in grep meaning 'no matches') so that we can use pipefail
_grep() { grep "$@" || test $? = 1; }

# First Install any required helm plugins
if [ -n "${PLUGINS_LIST}" ]; then
    plugins=${PLUGINS_LIST//,/ }
    for plugin in $plugins
    do
        echo "installing helm plugin: [$plugin]"
        helm plugin install $plugin
    done
fi

helm plugin list

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
KUBE_NAMESPACE_EXISTS=$(kubectl get namespaces | _grep ^${DEPLOY_NAMESPACE})
if [ -z "${KUBE_NAMESPACE_EXISTS}" ]; then
    echo "The namespace ${DEPLOY_NAMESPACE} does not exists. Creating..."
    kubectl create namespace "${DEPLOY_NAMESPACE}"
else
    echo "The namespace ${DEPLOY_NAMESPACE} exists. Skipping creation..."
fi


# Checking to see if a repo URL is in the path, if so add it or update.
if [ -n "${HELM_REPOSITORY}" ]; then
    HELM_CHART_NAME="${DEPLOY_CHART_PATH%/*}"

    HELM_REPOS=$(helm repo list || true)
    CHART_REPO_EXISTS=$(echo $HELM_REPOS | _grep ^${HELM_CHART_NAME})
    if [ -z "${CHART_REPO_EXISTS}" ]; then
        echo "Adding repo ${HELM_CHART_NAME} (${HELM_REPOSITORY})"
        helm repo add "${HELM_CHART_NAME}" "${HELM_REPOSITORY}"
    else
        echo "Updating repo ${HELM_CHART_NAME}"
        helm repo update "${HELM_CHART_NAME}"
    fi
fi

# Upgrade or install the chart.  This does it all.
HELM_COMMAND="helm upgrade --install --timeout ${TIMEOUT}"

# If we should wait, then do so 
if [ -n "${HELM_WAIT}" ]; then
    HELM_COMMAND="${HELM_COMMAND} --wait"
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
echo "Executing: ${HELM_COMMAND}"
${HELM_COMMAND}
