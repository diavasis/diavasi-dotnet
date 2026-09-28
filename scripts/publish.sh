#!/usr/bin/env bash
set -euo pipefail
version=$(python3 - <<'PY'
import re
text = open("Diavasi.Client/Diavasi.Client.csproj").read()
match = re.search(r"<Version>([^<]+)</Version>", text)
if not match:
    raise SystemExit("Version missing from Diavasi.Client.csproj")
print(match.group(1))
PY
)
tag="${GITHUB_REF_NAME:-}"
if [[ -n "$tag" && "$tag" != "v${version}" ]]; then
  echo "tag ${tag} does not match package version ${version}" >&2
  exit 1
fi
dotnet pack Diavasi.Client/Diavasi.Client.csproj -c Release -o nupkg
if [[ "${DRY_RUN:-0}" == 1 ]]; then
  exit 0
fi
if [[ -z "${NUGET_API_KEY:-}" ]]; then
  echo "NUGET_API_KEY is not set" >&2
  exit 1
fi
dotnet nuget push nupkg/*.nupkg --api-key "$NUGET_API_KEY" --source https://api.nuget.org/v3/index.json
