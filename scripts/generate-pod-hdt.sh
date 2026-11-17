#!/usr/bin/env bash
# Builds one HDT index per pod, for derived resources to be answered from without loading a pod into
# memory first. The index is written into the pod itself, as <pod>/.index.hdt.
#
# A pod's index holds exactly what its derived resources select: every .nq document below the pod,
# leaving out dot files and dot directories, as the server does. The documents of a pod are
# concatenated as they are, which is safe because SolidBench blank node labels are unique within a
# pod.
#
# Usage: scripts/generate-pod-hdt.sh [pods directory]
# Set JOBS to change how many pods are converted at once (defaults to the number of CPUs).
set -euo pipefail

PODS=$(realpath "${1:-generated/out-fragments/http/solidbench-server_3000/pods}")
JOBS=${JOBS:-$(nproc)}
IMAGE=rdfhdt/hdt-cpp:latest
# The image's rdf2hdt is a libtool wrapper that links the actual binary on every call, which needs
# root and costs more than converting a pod, so the binary is called directly.
HDT=/usr/local/src/hdt-cpp

TOTAL=$(find "$PODS" -mindepth 1 -maxdepth 1 -type d -not -name ".*" | wc -l)
echo "Converting $TOTAL pods in $PODS with $JOBS jobs"
START=$(date +%s)

# One container converts every pod, as starting a container per pod costs more than converting it.
# Each converted pod prints its name, which is counted here to report progress.
docker run --rm -i -u "$(id -u):$(id -g)" -e JOBS="$JOBS" \
  -e RDF2HDT="$HDT/libhdt/tools/.libs/rdf2hdt" -e LD_LIBRARY_PATH="$HDT/libhdt/.libs:$HDT/libcds/.libs" \
  -v "$PODS":/pods "$IMAGE" sh -s <<'EOF' |
cd /pods
find . -mindepth 1 -maxdepth 1 -type d -not -name ".*" | sed "s|^\./||" | xargs -P "$JOBS" -n 1 sh -c '
  pod=$1
  # The index itself is a dot file, so it is never part of its own input
  find "$pod" -name "*.nq" -not -path "*/.*" -exec cat {} + > "/tmp/$pod.nq"
  if "$RDF2HDT" -i "/tmp/$pod.nq" "$pod/.index.hdt" > "/tmp/$pod.log" 2>&1; then
    echo "$pod"
  else
    echo "Failed to convert $pod:" >&2
    cat "/tmp/$pod.log" >&2
  fi
  rm -f "/tmp/$pod.nq" "/tmp/$pod.log"
' _
EOF
awk -v total="$TOTAL" '{ done++ } done % 100 == 0 || done == total { printf "\rConverted %d/%d pods", done, total } END { print "" }'

CONVERTED=$(find "$PODS" -mindepth 2 -maxdepth 2 -name ".index.hdt" | wc -l)
echo "Converted $CONVERTED/$TOTAL pods in $(( $(date +%s) - START ))s"
if [ "$CONVERTED" -ne "$TOTAL" ]; then
  echo "Some pods could not be converted" >&2
  exit 1
fi
