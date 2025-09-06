#!/bin/bash
# Script: filter_networks.sh
# Purpose: Filter a network CSV into sub-networks and summarize nodes & edges
# Input: filtered_edges.csv
# Author: Donovin Coles

INPUT_FILE="filtered_edges.csv"

echo "Processing $INPUT_FILE"

# Function to filter edges and count nodes/edges
filter_network() {
    local OUTFILE=$1
    local FILTER_EXPR=$2
    local DESC=$3

    echo "Filtering $DESC network..."

    # Filter edges based on expression
    awk -F, "NR==1 || $FILTER_EXPR" "$INPUT_FILE" > "$OUTFILE"

    # Count edges
    TOTAL_EDGES=$(tail -n +2 "$OUTFILE" | wc -l)
    POS_EDGES=$(tail -n +2 "$OUTFILE" | awk -F, '$4=="Positive"' | wc -l)
    NEG_EDGES=$(tail -n +2 "$OUTFILE" | awk -F, '$4=="Negative"' | wc -l)

    # Count nodes
    NODES=$(tail -n +2 "$OUTFILE" | awk -F, '{print $1; print $2}' | sort | uniq | wc -l)

    echo "$DESC network summary:"
    echo "  Total edges: $TOTAL_EDGES"
    echo "  Positive edges: $POS_EDGES"
    echo "  Negative edges: $NEG_EDGES"
    echo "  Nodes: $NODES"
    echo ""
}

# 1. Pathogen ↔ Hyperparasite only (APSI_ + DN*)
filter_network "pathogen_hyper_only_edges.csv" '($1 !~ /^Eucgr\./ && $2 !~ /^Eucgr\./)' "Pathogen-Hyperparasite"

# 2. Plant ↔ Hyperparasite only (Eucgr. + DN*)
filter_network "plant_hyper_only_edges.csv" '(($1 ~ /^Eucgr\./ && $2 ~ /^DN/) || ($2 ~ /^Eucgr\./ && $1 ~ /^DN/))' "Plant-Hyperparasite"

# 3. Plant ↔ Pathogen only (Eucgr. + APSI_)
filter_network "plant_pathogen_only_edges.csv" '(($1 ~ /^Eucgr\./ && $2 ~ /^APSI_/) || ($2 ~ /^Eucgr\./ && $1 ~ /^APSI_/))' "Plant-Pathogen"

echo "All done."
