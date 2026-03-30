#!/bin/bash

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
  memory-requests             Show pod names with CPU and memory requests
  quota-summary               Show Quota Summary
  flavors                     Show Flavors Reservation and Usage
  all-info                    Show detailed pod information

Examples:
  $0 cpu-requests
  $0 memory-requests
EOF
}


# Command to show CPU requests
cmd_cpu_requests() {
    echo "---------------------------------------------------------------------------------------------------"
    kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{":"}{.resources.requests.cpu}{" "}{end}{"\n"}{end}' 2>/dev/null | \
        awk -F'\t' '
        BEGIN {
            # Initialize max lengths
            max_pod_len = length("Pod Name")
            max_cont_len = length("Container")
            max_cpu_len = length("CPU (millicores)")
            found = 0
        }
        NF>=2 && $1 != "" {
            found = 1
            pods[++count] = $1
            gsub(/[[:space:]]+$/, "", $2)  # Remove trailing spaces

            # Split container entries
            split($2, container_items, " ")
            container_count[count] = 0

            for (i in container_items) {
                if (container_items[i] != "") {
                    container_count[count]++
                    # Split container:CPU
                    split(container_items[i], parts, ":")
                    container_names[count, container_count[count]] = parts[1]
                    cpu_values[count, container_count[count]] = (length(parts) > 1) ? parts[2] : "N/A"

                    # Update max lengths
                    if (length(parts[1]) > max_cont_len) max_cont_len = length(parts[1])
                    if (length(cpu_values[count, container_count[count]]) > max_cpu_len) {
                        max_cpu_len = length(cpu_values[count, container_count[count]])
                    }
                }
            }

            # Update pod length
            if (length($1) > max_pod_len) max_pod_len = length($1)
        }
        END {
            if (!found) {
                print "No pods found or error retrieving data"
                exit
            }

            # Print header
            printf "%-" max_pod_len "s  %-" max_cont_len "s  %-" max_cpu_len "s\n",
                   "Pod Name", "Container", "CPU (millicores)"

            # Print separator line
            sep = ""
            for (i = 1; i <= max_pod_len; i++) sep = sep "-"
            sep = sep "  "
            for (i = 1; i <= max_cont_len; i++) sep = sep "-"
            sep = sep "  "
            for (i = 1; i <= max_cpu_len; i++) sep = sep "-"
            print sep

            # Print data
            for (i = 1; i <= count; i++) {
                if (container_count[i] > 0) {
                    # Print first container
                    printf "%-" max_pod_len "s  %-" max_cont_len "s  %-" max_cpu_len "s\n",
                           pods[i], container_names[i, 1], cpu_values[i, 1]

                    # Print additional containers
                    for (j = 2; j <= container_count[i]; j++) {
                        printf "%-" max_pod_len "s  %-" max_cont_len "s  %-" max_cpu_len "s\n",
                               "", container_names[i, j], cpu_values[i, j]
                    }
                } else {
                    printf "%-" max_pod_len "s  %-" max_cont_len "s  %-" max_cpu_len "s\n",
                           pods[i], "N/A", "N/A"
                }
            }
        }'
}


# Command to show CPU and memory requests
cmd_memory_requests() {
    echo "--------------------------------------------------------------------------"

    kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\t"}{.spec.containers[].resources.requests.memory}{"\n"}{end}' 2>/dev/null | \
        awk '
        BEGIN {
            # Track maximum lengths for each column
            max_pod_len = length("Pod Name")
            max_cpu_len = length("CPU (millicores)")
            max_mem_len = length("Memory")
            found = 0
        }
        /^[[:space:]]*$/ { next }  # Skip empty lines

        {
            # Split line into fields by tab
            split($0, fields, "\t")

            if (length(fields[1]) > 0) {
                found = 1
                pods[++count] = fields[1]
                cpus[count] = (fields[2] == "" ? "N/A" : fields[2])
                mems[count] = (fields[3] == "" ? "N/A" : fields[3])

                # Update maximum lengths
                pod_len = length(fields[1])
                if (pod_len > max_pod_len) max_pod_len = pod_len

                cpu_len = length(fields[2] == "" ? "N/A" : fields[2])
                if (cpu_len > max_cpu_len) max_cpu_len = cpu_len

                mem_len = length(fields[3] == "" ? "N/A" : fields[3])
                if (mem_len > max_mem_len) max_mem_len = mem_len
            }
        }
        END {
            if (!found) {
                print "No pods found or error retrieving data"
                exit
            }

            # Print header
            printf "%-" max_pod_len "s  %-" max_cpu_len "s  %-"max_mem_len "s\n",
                   "Pod Name", "CPU", "Memory"

            # Print separator line
            sep = ""
            for (i = 1; i <= max_pod_len; i++) sep = sep "-"
            sep = sep "  "
            for (i = 1; i <= max_cpu_len; i++) sep = sep "-"
            sep = sep "  "
            for (i = 1; i <= max_mem_len; i++) sep = sep "-"
            print sep

            # Print data with proper alignment
            for (i = 1; i <= count; i++) {
                printf "%-" max_pod_len "s  %-" max_cpu_len "s  %s\n",
                       pods[i], cpus[i], mems[i]
            }
        }'
}


# Command to show Flavors Reservation and Usage
cmd_flavors() {
    echo "---------------------------------------------------------------------------------------"
    kubectl describe localqueue default | awk '
    /Flavors Reservation:/ {mode="Reservation"; next}
    /Flavors Usage:/       {mode="Usage"; next}

    /Name:[[:space:]]+/ && !flavor {
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

# Command to show Quota Summary
cmd_quota_summary() {
    # Get queue info
    read CLUSTERQUEUE PENDING_WORKLOADS ADMITTED_WORKLOADS <<< $(kubectl get localqueue default --no-headers 2>/dev/null | awk '{print $2, $3, $4}')

    # Extract the flavor name
    FLAVOR_NAME=$(kubectl describe clusterqueue "${CLUSTERQUEUE}" 2>/dev/null |
        awk '/Flavors:/{fl=1} fl && /Name:/ && !/Resources:/ {print $NF; exit}')

    echo -e "${NC}-----------------------------------------------------------${NC}"
    echo -e "${BLUE}GPU Quota: ${BLUE}${CLUSTERQUEUE}${NC}"
    echo -e "${BLUE}Pending: ${BLUE}${PENDING_WORKLOADS}${NC} | ${BLUE}Admitted: ${ADMITTED_WORKLOADS}${NC}"
    echo -e "${NC}-----------------------------------------------------------${NC}"

    kubectl describe clusterqueue "${CLUSTERQUEUE}" 2>/dev/null | awk -v flavor="$FLAVOR_NAME" '
        BEGIN {
            # Create the header with flavor in brackets
            header = "RESOURCE"
            if (flavor != "") {
                header = header " (Flavor: " flavor ")"
            }
            printf "%-35s %-15s\n", header, "NOMINAL QUOTA"
            printf "%-35s %-15s\n", "-----------------------------------", "---------------"
        }
        /Flavors:/{fl=1}
        fl && /Resources:/{rs=1; fl=0}
        rs && /Name:/ && $0 !~ flavor {
            resource=$NF
            getline
            if ($0 ~ /Nominal Quota:/) {
                quota=$NF
                printf "%-35s %-15s\n", resource, quota
            }
        }
    '
}

# Commands to show all pod information
cmd_all_info() {
    echo -e "${BLUE}=== All Pod Information ===${NC}"

    echo -e "\n${GREEN}Basic Pod Status:${NC}"
    kubectl get pods

    echo -e "\n${GREEN}Pods with CPU Requests:${NC}"
    cmd_cpu_requests

    echo -e "\n${GREEN}Pod Resource for Memory Requests:${NC}"
    cmd_memory_requests

    echo -e "\n${GREEN}Show quota summary:${NC}"
    cmd_quota_summary

    echo -e "\n${GREEN}Show workloads with Flavors Reservation and Usage:${NC}"
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
    quota-summary|quota)
        cmd_quota_summary
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
