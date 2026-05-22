#!/bin/bash
set -euo pipefail

REPO="${POD_REPO:-BoostApplePods}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"
PODSPEC_FILE="${ROOT_DIR}/PODSPEC"
SCRIPT_VERSION='`scripts/version.sh`'
VERSIONS_REPLACED=0
PODSPECS=()

cd "$ROOT_DIR"

if [[ ! -f "$PODSPEC_FILE" ]]; then
  echo "PODSPEC file not found: $PODSPEC_FILE" >&2
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue

  if [[ "$line" != *.podspec ]]; then
    line="${line}.podspec"
  fi

  PODSPECS+=("$line")
done < "$PODSPEC_FILE"

if [[ "${#PODSPECS[@]}" -eq 0 ]]; then
  echo "No podspec entries found in PODSPEC" >&2
  exit 1
fi

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "VERSION file not found: $VERSION_FILE" >&2
  exit 1
fi

REAL_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
EXPECTED_VERSION="${1:-$REAL_VERSION}"

if [[ -z "$REAL_VERSION" ]]; then
  echo "VERSION is empty" >&2
  exit 1
fi

if [[ ! "$REAL_VERSION" =~ ^[0-9]+(\.[0-9]+){2,3}$ ]]; then
  echo "Invalid VERSION: $REAL_VERSION" >&2
  exit 1
fi

if [[ "$EXPECTED_VERSION" != "$REAL_VERSION" ]]; then
  echo "Version argument ($EXPECTED_VERSION) does not match VERSION ($REAL_VERSION)" >&2
  exit 1
fi

if ! git tag --points-at HEAD | grep -Fxq "$REAL_VERSION"; then
  echo "Current HEAD is not tagged with VERSION: $REAL_VERSION" >&2
  exit 1
fi

if ! git ls-remote --exit-code --tags origin "refs/tags/${REAL_VERSION}" >/dev/null; then
  echo "Remote tag refs/tags/${REAL_VERSION} does not exist on origin" >&2
  exit 1
fi

restore_versions() {
  if [[ "$VERSIONS_REPLACED" != "1" ]]; then
    return
  fi

  for spec in "${PODSPECS[@]}"; do
    [[ -f "$spec" ]] || continue
    sed -i '' "s|s.version          = \"$REAL_VERSION\"|s.version          = $SCRIPT_VERSION|" "$spec"
  done
}

trap restore_versions EXIT

for spec in "${PODSPECS[@]}"; do
  if [[ ! -f "$spec" ]]; then
    echo "Missing podspec: $spec" >&2
    exit 1
  fi

  if ! grep -Fq "s.version          = $SCRIPT_VERSION" "$spec"; then
    echo "Unexpected version line in $spec" >&2
    exit 1
  fi

  if ! grep -Fq ":tag => s.version" "$spec"; then
    echo "Unexpected source tag in $spec" >&2
    exit 1
  fi
done

for spec in "${PODSPECS[@]}"; do
  sed -i '' "s|s.version          = $SCRIPT_VERSION|s.version          = \"$REAL_VERSION\"|" "$spec"
done
VERSIONS_REPLACED=1

for spec in "${PODSPECS[@]}"; do
  echo "Pushing $spec..."
  pod repo push "$REPO" "$spec" --sources="$REPO,https://github.com/CocoaPods/Specs.git" --allow-warnings --skip-import-validation --verbose --skip-tests --use-modular-headers
done

restore_versions
VERSIONS_REPLACED=0
trap - EXIT

for spec in "${PODSPECS[@]}"; do
  if ! grep -Fq "s.version          = $SCRIPT_VERSION" "$spec"; then
    echo "Failed to restore version line in $spec" >&2
    exit 1
  fi
done

echo "Done!"
