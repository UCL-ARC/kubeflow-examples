#!/bin/bash

# ============================================================================
# Script: pod-info.sh
# Description: Simplified interface for common pod information queries
# 
# Usage: pod-info.sh [OPTIONS] COMMAND

# Options:
#   -n, --namespace NAMESPACE   Kubernetes namespace (default: default)
#   -h, --help                  Show this help message

# Commands:
#   cpu-requests                Show pod names with CPU requests
#   image-pull-errors           Show pods with ImagePullBackOff errors
#   running                     Show only running pods
#   resources                   Show pod names with CPU and memory requests
#   all-info                    Show detailed pod information

# Examples:
#   pod-info.sh cpu-requests
#   pod-info.sh -n production image-pull-errors
#   pod-info.sh resources

# Notation
# You can use commands directly in the terminal as follows
# For Lists all Pods that Prints the Pod name followed by the CPU request for each container. 
# Useful for checking resource requests across workloads.
# ```bash
# kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\n"}{end}'
# ```
# Filter Pods Using jq that  Retrieves all Pods in JSON format. Uses jq to filter Pods that are failing to pull container images. Prints only the names of affected Pods.
# This is particularly useful for quickly identifying broken or misconfigured workloads.
# ```bash
# kubectl get pods -o json | jq -r '.items[]| select(.status.phase=="Running").metadata.name'
# ```
#
# ============================================================================


set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default namespace
NAMESPACE="default"

# Help function
show_help() {
    cat << EOF
Pod Information Script - Simplified kubectl queries

Usage: $0 [OPTIONS] COMMAND

Options:
  -n, --namespace NAMESPACE   Kubernetes namespace (default: default)
  -h, --help                  Show this help message

Commands:
  cpu-requests                Show pod names with CPU requests
  image-pull-errors           Show pods with ImagePullBackOff errors
  running                     Show only running pods
  resources                   Show pod names with CPU and memory requests
  all-info                    Show detailed pod information

Examples:
  $0 cpu-requests
  $0 -n production image-pull-errors
  $0 resources
EOF
}

# Function to run kubectl with namespace
kubectl_ns() {
    kubectl -n "$NAMESPACE" "$@"
}

# Command 1: Show CPU requests
cmd_cpu_requests() {
    echo -e "${BLUE}=== Pod CPU Requests ===${NC}"
    echo -e "${GREEN}Pod Name\tCPU Request${NC}"
    echo "--------------------------------"
    kubectl_ns get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\n"}{end}' | \
        column -t -s $'\t' || echo "No pods found or error retrieving data"
}

# Command 2: Show ImagePullBackOff errors
cmd_image_pull_errors() {
    echo -e "${BLUE}=== Pods with ImagePullBackOff Errors ===${NC}"
    pods=$(kubectl_ns get pods -o json | jq -r '.items[] | select(.status.phase=="ImagePullBackOff" or (.status.containerStatuses[]? | .state.waiting.reason=="ImagePullBackOff")) | .metadata.name')
    
    if [[ -z "$pods" ]]; then
        echo -e "${GREEN}No pods with ImagePullBackOff errors found${NC}"
    else
        echo -e "${RED}Found pods with ImagePullBackOff:${NC}"
        echo "$pods"
    fi
}

# Command 3: Show running pods
cmd_running_pods() {
    echo -e "${BLUE}=== Running Pods ===${NC}"
    kubectl_ns get pods -o json | jq -r '.items[] | select(.status.phase=="Running") | .metadata.name' | \
        while read -r pod; do
            echo -e "${GREEN}✓${NC} $pod"
        done
}

# Command 4: Show CPU and memory requests
cmd_resources() {
    echo -e "${BLUE}=== Pod Resource Requests ===${NC}"
    echo -e "${GREEN}Pod Name\tCPU\tMemory${NC}"
    echo "----------------------------------------"
    kubectl_ns get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\t"}{.spec.containers[].resources.requests.memory}{"\n"}{end}' | \
        column -t -s $'\t' || echo "No pods found or error retrieving data"
}

# Command 5: Show all pod information
cmd_all_info() {
    echo -e "${BLUE}=== All Pod Information ===${NC}"
    echo "Getting pod information..."
    
    echo -e "\n${YELLOW}1. Basic Pod Status:${NC}"
    kubectl_ns get pods
    
    echo -e "\n${YELLOW}2. Pods with CPU Requests:${NC}"
    cmd_cpu_requests
    
    echo -e "\n${YELLOW}3. Pods with ImagePullBackOff:${NC}"
    cmd_image_pull_errors
    
    echo -e "\n${YELLOW}4. Running Pods:${NC}"
    cmd_running_pods
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            COMMAND="$1"
            shift
            break
            ;;
    esac
done

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if jq is available (for commands that need it)
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is not installed. Some commands may not work properly.${NC}"
fi

# Check if command was provided
if [[ -z "${COMMAND:-}" ]]; then
    echo -e "${RED}Error: No command specified${NC}"
    show_help
    exit 1
fi

# Execute the requested command
case "$COMMAND" in
    cpu-requests|cpu)
        cmd_cpu_requests
        ;;
    image-pull-errors|image-errors)
        cmd_image_pull_errors
        ;;
    running|running-pods)
        cmd_running_pods
        ;;
    resources|resource-requests)
        cmd_resources
        ;;
    all-info|all)
        cmd_all_info
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}"
        show_help
        exit 1
        ;;
esac