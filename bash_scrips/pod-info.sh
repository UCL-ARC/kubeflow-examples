#!/bin/bash

# ============================================================================
# Script: pod-info.sh
# Description: Simplified interface for common pod information queries
#
# Usage: pod-info.sh COMMAND
#
# Commands:
#   cpu-requests                Show pod names with CPU requests
#   resources                   Show pod names with CPU and memory requests
#   all-info                    Show detailed pod information
#
# Examples:
#   pod-info.sh cpu-requests
#   pod-info.sh resources
#
# Notes:
# - Uses the namespace from the current kubectl context
# ============================================================================

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
Pod Information Script - Simplified kubectl queries

Usage: $0 [OPTIONS] COMMAND

Options:
  -h, --help                  Show this help message

Commands:
  cpu-requests                Show pod names with CPU requests
  memory-requests                   Show pod names with CPU and memory requests
  flavors                     Show Flavors Reservation and Usage
  all-info                    Show detailed pod information

Examples:
  $0 cpu-requests
  $0 memory-requests
EOF
}


# Command 1: Show CPU requests
cmd_cpu_requests() {
    echo -e "${BLUE}=== Pod CPU Requests ===${NC}"
    echo -e "${GREEN}Pod Name\tper-container:Number of CPUs Requested${NC}"
    echo "--------------------------------"
    kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{":"}{.resources.requests.cpu}{" "}{end}{"\n"}{end}' | \
        column -t -s $'\t' || echo "No pods found or error retrieving data"
}

# Command 2: Show CPU and memory requests
cmd_memory_requests() {
    echo -e "${BLUE}=== Pod Resource Requests ===${NC}"
    echo -e "${GREEN}Pod Name\tCPU\tMemory${NC}"
    echo "----------------------------------------"
    kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\t"}{.spec.containers[].resources.requests.memory}{"\n"}{end}' | \
        column -t -s $'\t' || echo "No pods found or error retrieving data"
}

# Command 3: Show Flavors Reservation and Usage
cmd_flavors() {
    echo -e "${BLUE}=== Flavors Reservation and Usage ===${NC}"
    echo -e "${GREEN}Flavor\tTotal${NC}"
    echo "---------------------------------------------------------------------------------------"
    kubectl describe localqueue default | awk '
    /Flavors Reservation:/ {mode="Reservation"; next}
    /Flavors Usage:/       {mode="Usage"; next}

    /Name:[[:space:]]+a/ && !flavor {
    flavor=$2
    next
    }

    /Name:[[:space:]]+(cpu|memory|ephemeral-storage|nvidia.com\/gpu|pods)/ {
    res=$2
    getline
    val=$2
    data[res,mode]=val
    }

    END {
    printf "%-25s %-30s %-30s\n",
            "RESOURCE",
            "RESERVED (" flavor ")",
            "USED (" flavor ")"

    printf "%-25s %-30s %-30s\n",
            "------------------------",
            "------------------------------",
            "------------------------------"

    for (k in data) {
        split(k, a, SUBSEP)
        resources[a[1]]=1
    }

    for (r in resources) {
        printf "%-25s %-30s %-30s\n",
            r,
            data[r,"Reservation"],
            data[r,"Usage"]
    }
    }'
}


# Command 4: Show all pod information
cmd_all_info() {
    echo -e "${BLUE}=== All Pod Information ===${NC}"

    echo -e "\n${YELLOW}1. Basic Pod Status:${NC}"
    kubectl get pods

    echo -e "\n${YELLOW}2. Pods with CPU Requests:${NC}"
    cmd_cpu_requests

    echo -e "\n${YELLOW}3. Pod Resource for Memory Requests:${NC}"
    cmd_memory_requests

    echo -e "\n${YELLOW}4. Show workloads with Flavors Reservation and Usage:${NC}"
    cmd_flavors
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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

if [[ -z "${COMMAND:-}" ]]; then
    echo -e "${RED}Error: No command specified${NC}"
    show_help
    exit 1
fi

# Check dependencies
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Execute command
case "$COMMAND" in
    cpu-requests|cpu)
        cmd_cpu_requests
        ;;
    memory-requests|mem)
        cmd_memory_requests
        ;;
    flavors|resource-flavors)
        cmd_flavors
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
