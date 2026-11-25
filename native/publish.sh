#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <arm|amd64> <layer|all> <region|all>" >&2
  echo "Example: $0 amd64 php-86al2023 us-east-1" >&2
  echo "Example: $0 arm all eu-west-1" >&2
  echo "Example: $0 amd64 php-86al2023 all" >&2
  echo "Example: $0 arm all all" >&2
  exit 1
fi

ARCH="$1"
LAYER_ARG="$2"
REGION_ARG="$3"

case "$ARCH" in
  arm|amd64) ;;
  *)
    echo "Invalid architecture: $ARCH (must be 'arm' or 'amd64')" >&2
    exit 1
    ;;
esac

declare -A ALL_LAYERS=(
  ["php-83al2023"]="Laravel Vapor PHP 8.3 for Amazon Linux 2023"
  ["php-83al2023-arm"]="Laravel Vapor PHP 8.3 for Amazon Linux 2023 ARM"
  ["php-84al2023"]="Laravel Vapor PHP 8.4 for Amazon Linux 2023"
  ["php-84al2023-arm"]="Laravel Vapor PHP 8.4 for Amazon Linux 2023 ARM"
  ["php-85al2023"]="Laravel Vapor PHP 8.5 for Amazon Linux 2023"
  ["php-85al2023-arm"]="Laravel Vapor PHP 8.5 for Amazon Linux 2023 ARM"
  ["php-86al2023"]="Laravel Vapor PHP 8.6 for Amazon Linux 2023"
  ["php-86al2023-arm"]="Laravel Vapor PHP 8.6 for Amazon Linux 2023 ARM"
)

REGIONS=(
  us-east-1
  us-east-2
  us-west-1
  us-west-2
  ap-east-1
  ap-south-1
  ap-northeast-3
  ap-northeast-2
  ap-southeast-1
  ap-southeast-2
  ap-southeast-3
  ap-northeast-1
  af-south-1
  ca-central-1
  eu-central-1
  eu-west-1
  eu-west-2
  eu-west-3
  eu-north-1
  eu-south-1
  sa-east-1
)

# Filter layers by architecture
declare -A LAYERS=()
for key in "${!ALL_LAYERS[@]}"; do
  if [[ "$ARCH" == "arm" && "$key" == *-arm ]]; then
    LAYERS["$key"]="${ALL_LAYERS[$key]}"
  elif [[ "$ARCH" == "amd64" && "$key" != *-arm ]]; then
    LAYERS["$key"]="${ALL_LAYERS[$key]}"
  fi
done

# Resolve layers to publish
if [[ "$LAYER_ARG" == "all" ]]; then
  LAYERS_TO_PUBLISH=("${!LAYERS[@]}")
else
  if [[ -z "${LAYERS[$LAYER_ARG]+x}" ]]; then
    echo "Layer '$LAYER_ARG' is not available for architecture '$ARCH'" >&2
    exit 1
  fi
  LAYERS_TO_PUBLISH=("$LAYER_ARG")
fi

# Resolve regions to publish
if [[ "$REGION_ARG" == "all" ]]; then
  REGIONS_TO_PUBLISH=("${REGIONS[@]}")
else
  REGIONS_TO_PUBLISH=("$REGION_ARG")
fi

echo "Publishing ${#LAYERS_TO_PUBLISH[@]} layer(s) to ${#REGIONS_TO_PUBLISH[@]} region(s) ($ARCH)"

for region in "${REGIONS_TO_PUBLISH[@]}"; do
  for layer in "${LAYERS_TO_PUBLISH[@]}"; do
    zip_file="./export/${layer}.zip"

    if [[ ! -f "$zip_file" ]]; then
      echo "Missing zip: $zip_file" >&2
      exit 1
    fi
  done
done

for region in "${REGIONS_TO_PUBLISH[@]}"; do
  for layer in "${LAYERS_TO_PUBLISH[@]}"; do
    description="${LAYERS[$layer]}"
    zip_file="./export/${layer}.zip"

    version_arn=$(aws lambda publish-layer-version \
      --region "$region" \
      --layer-name "vapor-${layer}" \
      --description "$description" \
      --zip-file "fileb://${zip_file}" \
      --query 'LayerVersionArn' \
      --output text)

    version_number=$(echo "$version_arn" | awk -F: '{print $NF}')

    aws lambda add-layer-version-permission \
      --region "$region" \
      --layer-name "vapor-${layer}" \
      --version-number "$version_number" \
      --statement-id "public-$(date +%s%N)" \
      --action lambda:GetLayerVersion \
      --principal '*' \
      --output text >/dev/null

    echo "[$region] $layer: $version_arn"
  done
done