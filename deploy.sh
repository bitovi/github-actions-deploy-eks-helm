#!/usr/bin/env bash
set -euo pipefail

# catch exit 1 (which is a special case in grep meaning 'no matches') so that we can use pipefail
_grep() { grep "$@" || test $? = 1; }

HELM_AUTH=""
OCI_REGISTRY=false

# Check repository type

if [ -n "${HELM_REPOSITORY}" ]; then
    if [[ ${HELM_REPOSITORY} =~ ^http.* ]]; then
        OCI_REGISTRY=false
    else
        if [[ ${HELM_REPOSITORY} =~ ^oci.* ]]; then
            OCI_REGISTRY=true
        else
            echo "::error::Protocol handler expected here. Need http or oci."
            exit 1
        fi
    fi
fi

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

# If defined, will set up authentication parameters
if [ "${HELM_ACTION}" == "install" ] && [ "${OCI_REGISTRY}" != "true" ]; then

    # Authentication management

    if [ -n "$CA_FILE" ]; then
        HELM_AUTH="${HELM_AUTH} --ca-file ${CA_FILE}"
    fi

    if [ -n "$CERT_FILE" ]; then
        HELM_AUTH="${HELM_AUTH} --cert-file ${CERT_FILE}"
    fi

    if [ -n "$KEY_FILE" ]; then
        HELM_AUTH="${HELM_AUTH} --key-file ${KEY_FILE}"
    fi

    if [ -n "$SKIP_TLS" ]; then
        HELM_AUTH="${HELM_AUTH} --insecure-skip-tls-verify"
    fi

    if [ -n "$PASS_CREDENTIALS" ]; then
        HELM_AUTH="${HELM_AUTH} --pass-credentials"
    fi

    if [ -n "$REPO_USERNAME" ]; then
        HELM_AUTH="${HELM_AUTH} --username ${REPO_USERNAME}"
    fi

    if [ -n "$REPO_PASSWORD" ]; then
        HELM_AUTH="${HELM_AUTH} --password ${REPO_PASSWORD}"
    fi
fi

# Checking to see if a repo URL is in the path, if so add it or update. Validate it's not an OCI based registry.
if [ -n "${HELM_REPOSITORY}" ] && [ "${OCI_REGISTRY}" != "true" ]; then
    HELM_CHART_NAME="${DEPLOY_CHART_PATH%/*}"

    CHART_REPO_EXISTS=$(helm repo list | _grep ^${HELM_CHART_NAME})
    if [ -z "${CHART_REPO_EXISTS}" ]; then
        echo "Adding repo ${HELM_CHART_NAME} (${HELM_REPOSITORY})"
        helm repo add ${HELM_CHART_NAME} ${HELM_REPOSITORY} ${HELM_AUTH}
            if ! [ $? == 0 ]; then
                echo "::error::Something went wrong adding the helm repository."
                echo "Please check the logs. If you consider this a bug, please submit an issue in our repo."
                exit 1
            fi
    else
        echo "Updating repo ${HELM_CHART_NAME}"
        helm repo update "${HELM_CHART_NAME}"
            if ! [ $? == 0 ]; then
                echo "::error::Something went wrong updating the helm repository."
                exit 1
            fi
    fi
fi

# If OCI registry, we need to login before performing any action

if [ "${OCI_REGISTRY}" == "true" ] ; then
    if [ -z "${REPO_PASSWORD}" ] || [ -z "${REPO_USERNAME}" ] ; then
        echo "Missing credentials to login to ECR registry"
    else
        echo "Logging into helm registry"
        echo "${REPO_PASSWORD}" | helm registry login ${HELM_REPOSITORY#oci://} --username ${REPO_USERNAME} --password-stdin
        if ! [ $? == 0 ]; then
            echo "::error::Something went wrong with logging into the ECR Registry."
            exit 1
        fi
    fi
fi

# Proceed with installation procedure

if [ "${HELM_ACTION}" == "install" ]; then
    # Upgrade or install the chart.  This does it all.
    HELM_COMMAND="helm upgrade --install --create-namespace --timeout ${TIMEOUT}  ${HELM_AUTH}"

    # If we should wait, then do so
    if [ -n "${HELM_WAIT}" ]; then
        HELM_COMMAND="${HELM_COMMAND} --wait"
    fi

    # Add atomic flag
    if [ -n "${HELM_ATOMIC}" ]; then
        HELM_COMMAND="${HELM_COMMAND} --atomic"
    fi

    for config_file in ${DEPLOY_CONFIG_FILES//,/ }
    do
        HELM_COMMAND="${HELM_COMMAND} -f ${config_file}"
    done

    if [ -n "$DEPLOY_VALUES" ]; then
        HELM_COMMAND="${HELM_COMMAND} --set ${DEPLOY_VALUES}"
    fi

    if [ -n "$VERSION" ]; then
        HELM_COMMAND="${HELM_COMMAND} --version ${VERSION}"
    fi

    if [ "${UPDATE_DEPS}" == "true" ]; then
        HELM_COMMAND="${HELM_COMMAND} --dependency-update"
    fi


elif [ "${HELM_ACTION}" == "uninstall" ]; then
    HELM_COMMAND="helm uninstall --timeout ${TIMEOUT}"

else
    echo "::error:: HELM_ACTION specified doesn't exist in this context. Please use 'install' or 'uninstall'"
    exit 2
fi

if [ -n "$DEPLOY_NAMESPACE" ]; then
    HELM_COMMAND="${HELM_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi

# Execute Commands
HELM_COMMAND="${HELM_COMMAND} ${DEPLOY_NAME}"

if [ "${HELM_ACTION}" == "install" ]; then
    if [ "${OCI_REGISTRY}" == "true" ]; then
        DEPLOY_CHART_PATH="${HELM_REPOSITORY}/${DEPLOY_CHART_PATH}"
    fi
    HELM_COMMAND="${HELM_COMMAND} ${DEPLOY_CHART_PATH}"
fi

echo "Executing: ${HELM_COMMAND}"
${HELM_COMMAND}
