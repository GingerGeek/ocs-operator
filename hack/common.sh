#!/bin/bash

# shellcheck disable=SC2034
# disable unused variable warnings

GO111MODULE="on"
GOPROXY="https://proxy.golang.org"
GOROOT="${GOROOT:-go env GOROOT}"

# Current DEV version of the CSV
DEFAULT_CSV_VERSION="4.6.0"
CSV_VERSION="${CSV_VERSION:-${DEFAULT_CSV_VERSION}}"

IMAGE_BUILD_CMD="${IMAGE_BUILD_CMD}"
if [ -z "$IMAGE_BUILD_CMD" ]; then
    IMAGE_BUILD_CMD=$(command -v docker || echo "")
fi
if [ -z "$IMAGE_BUILD_CMD" ]; then
    IMAGE_BUILD_CMD=$(command -v podman || echo "")
fi

IMAGE_RUN_CMD="${IMAGE_RUN_CMD:-${IMAGE_BUILD_CMD} run --rm -it}"

OUTDIR="build/_output"
OUTDIR_BIN="build/_output/bin"
OUTDIR_OCS_CI="build/_output/ocs-ci-testsuite"
OUTDIR_TEMPLATES="$OUTDIR/csv-templates"
OUTDIR_CRDS="$OUTDIR_TEMPLATES/crds"
OUTDIR_BUNDLEMANIFESTS="$OUTDIR_TEMPLATES/bundlemanifests"
OUTDIR_TOOLS="$OUTDIR/tools"
OUTDIR_CLUSTER_DEPLOY_MANIFESTS="$OUTDIR/cluster-deploy-manifests"

DEPLOY_YAML_PATH="deploy/deploy-with-olm.yaml"

REDHAT_OCS_CI_DEFAULT_TEST_EXPRESSION="TestOSCBasics or TestPvCreation or TestRawBlockPV or TestReclaimPolicy or TestCreateSCSameName or TestBasicPVCOperations or TestVerifyAllFieldsInScYamlWithOcDescribe"
REDHAT_OCS_CI_REPO="${REDHAT_OCS_CI_REPO:-https://github.com/red-hat-storage/ocs-ci}"
REDHAT_OCS_CI_HASH="${REDHAT_OCS_CI_HASH:-}"
REDHAT_OCS_CI_TEST_EXPRESSION="${REDHAT_OCS_CI_TEST_EXPRESSION:-$REDHAT_OCS_CI_DEFAULT_TEST_EXPRESSION}"
REDHAT_OCS_CI_PYTHON_BINARY="${REDHAT_OCS_CI_PYTHON_BINARY:-python3.7}"
REDHAT_OCS_CI_FORCE_TOOL_POD_INSTALL="${REDHAT_OCS_CI_FORCE_TOOL_POD_INSTALL:-false}"

# This env var allows developers to point to a custom oc tool that isn't in $PATH
# defaults to just using the 'oc' binary provided in $PATH
OCS_OC_PATH="${OCS_OC_PATH:-oc}"
OCS_FINAL_DIR="deploy/olm-catalog/ocs-operator/manifests"

NOOBAA_CSV="$OUTDIR_TEMPLATES/noobaa-csv.yaml"
ROOK_CSV="$OUTDIR_TEMPLATES/rook-csv.yaml.in"
OCS_CSV="$OUTDIR_TEMPLATES/ocs-operator.csv.yaml.in"

DEFAULT_IMAGE_REGISTRY="quay.io"
DEFAULT_REGISTRY_NAMESPACE="ocs-dev"
DEFAULT_IMAGE_TAG="latest"
DEFAULT_OPERATOR_IMAGE_NAME="ocs-operator"
DEFAULT_OPERATOR_BUNDLE_NAME="ocs-operator-bundle"
DEFAULT_OPERATOR_INDEX_NAME="ocs-operator-index"
DEFAULT_CATALOG_IMAGE_NAME="ocs-registry"
DEFAULT_MUST_GATHER_IMAGE_NAME="ocs-must-gather"

IMAGE_REGISTRY="${IMAGE_REGISTRY:-${DEFAULT_IMAGE_REGISTRY}}"
REGISTRY_NAMESPACE="${REGISTRY_NAMESPACE:-${DEFAULT_REGISTRY_NAMESPACE}}"
OPERATOR_IMAGE_NAME="${OPERATOR_IMAGE_NAME:-${DEFAULT_OPERATOR_IMAGE_NAME}}"
OPERATOR_BUNDLE_NAME="${OPERATOR_BUNDLE_NAME:-${DEFAULT_OPERATOR_BUNDLE_NAME}}"
OPERATOR_INDEX_NAME="${OPERATOR_INDEX_NAME:-${DEFAULT_OPERATOR_INDEX_NAME}}"
CATALOG_IMAGE_NAME="${CATALOG_IMAGE_NAME:-${DEFAULT_CATALOG_IMAGE_NAME}}"
MUST_GATHER_IMAGE_NAME="${MUST_GATHER_IMAGE_NAME:-${DEFAULT_MUST_GATHER_IMAGE_NAME}}"
IMAGE_TAG="${IMAGE_TAG:-${DEFAULT_IMAGE_TAG}}"
OPERATOR_FULL_IMAGE_NAME="${IMAGE_REGISTRY}/${REGISTRY_NAMESPACE}/${OPERATOR_IMAGE_NAME}:${IMAGE_TAG}"
BUNDLE_FULL_IMAGE_NAME="${IMAGE_REGISTRY}/${REGISTRY_NAMESPACE}/${OPERATOR_BUNDLE_NAME}:${IMAGE_TAG}"
INDEX_FULL_IMAGE_NAME="${IMAGE_REGISTRY}/${REGISTRY_NAMESPACE}/${OPERATOR_INDEX_NAME}:${IMAGE_TAG}"
CATALOG_FULL_IMAGE_NAME="${IMAGE_REGISTRY}/${REGISTRY_NAMESPACE}/${CATALOG_IMAGE_NAME}:${IMAGE_TAG}"
MUST_GATHER_FULL_IMAGE_NAME="${IMAGE_REGISTRY}/${REGISTRY_NAMESPACE}/${MUST_GATHER_IMAGE_NAME}:${IMAGE_TAG}"

OCS_CLUSTER_UNINSTALL="${OCS_CLUSTER_UNINSTALL:-true}"
OCS_SUBSCRIPTION_CHANNEL=${OCS_SUBSCRIPTION_CHANNEL:-alpha}

UPGRADE_FROM_OCS_REGISTRY_IMAGE="${UPGRADE_FROM_OCS_REGISTRY_IMAGE:-quay.io/ocs-dev/ocs-registry:4.2.0}"
UPGRADE_FROM_OCS_SUBSCRIPTION_CHANNEL="${UPGRADE_FROM_OCS_SUBSCRIPTION_CHANNEL:-$OCS_SUBSCRIPTION_CHANNEL}"

OS_TYPE=$(uname)

# Override the image name when this is invoked from openshift ci
if [ -n "$OPENSHIFT_BUILD_NAMESPACE" ]; then
	CATALOG_FULL_IMAGE_NAME="registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:${CATALOG_IMAGE_NAME}"
	echo "Openshift CI detected, deploying using image $CATALOG_FULL_IMAGE_NAME"
	MUST_GATHER_FULL_IMAGE_NAME="registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:ocs-must-gather-quay"
fi
