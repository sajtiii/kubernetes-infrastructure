#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# lint.sh — run super-linter locally via Docker
#
# Usage:
#   ./lint.sh           # lint only
#   ./lint.sh --fix     # lint and auto-fix where possible
# ---------------------------------------------------------------------------

SUPER_LINTER_IMAGE="ghcr.io/super-linter/super-linter:latest"
FIX=false

for arg in "$@"; do
  case "$arg" in
    --fix) FIX=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

DOCKER_ARGS=(
  --rm
  --env RUN_LOCAL=true
  --env DEFAULT_BRANCH=main
  --env VALIDATE_ALL_CODEBASE=true

  # Linters to run
  --env VALIDATE_YAML=true
  --env VALIDATE_HELM=true

  # Exclude Helm template files from YAML linting (Go template syntax)
  --env FILTER_REGEX_EXCLUDE=".*/templates/.*"

  --env YAML_CONFIG_FILE=.yamllint.yml

  --volume "$(pwd):/tmp/lint"
)

if [ "$FIX" = true ]; then
  echo "Fixing YAML files with prettier (excluding Helm templates)..."
  # Collect YAML files outside of templates/ directories
  mapfile -t yaml_files < <(find . -name '*.yaml' -o -name '*.yml' | grep -v '/templates/' | grep -v '^\./\.git' | sed 's|^\./||' | sort)
  if [ ${#yaml_files[@]} -gt 0 ]; then
    docker run --rm \
      --volume "$(pwd):/work" \
      --workdir /work \
      node:alpine \
      sh -c "npx --yes prettier --write ${yaml_files[*]}"
  fi
  echo "Fix complete."
fi

echo "Running super-linter..."
docker run "${DOCKER_ARGS[@]}" "$SUPER_LINTER_IMAGE"
