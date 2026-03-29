#!/usr/bin/env bash
# Build and push a multi-platform image (linux/amd64 + linux/arm64) for Docker Hub.
# Requires: docker login, docker buildx
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${IMAGE:-wayhomeservices/webapp-base}"
TAG="${TAG:-latest}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required" >&2
  exit 1
fi

# Use host BuildKit (docker driver). Nested docker-container builders often OOM on gem steps.
# Colima only allows one docker-driver instance — use its "colima" builder when it exists.
if docker buildx inspect colima >/dev/null 2>&1; then
  docker buildx use colima
elif docker buildx inspect multiarch >/dev/null 2>&1; then
  docker buildx use multiarch
else
  docker buildx create --name multiarch --driver docker --bootstrap
  docker buildx use multiarch
fi

docker buildx build \
  --platform "${PLATFORMS}" \
  -t "${IMAGE}:${TAG}" \
  --push \
  "${ROOT}"

echo "Pushed ${IMAGE}:${TAG} for ${PLATFORMS}"
