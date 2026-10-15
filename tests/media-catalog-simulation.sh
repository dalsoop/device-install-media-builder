#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$script_dir/.." && pwd)
catalog=$repo_root/work/device-install-media/catalog.json
verify=$repo_root/usb-media/verify-catalog
render=$repo_root/usb-media/render-ventoy-config
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT HUP INT TERM

fail() {
    echo "media-catalog-simulation: $*" >&2
    exit 1
}

expect_rejected() {
    fixture=$1
    if "$verify" "$fixture" >/dev/null 2>&1; then
        fail "invalid fixture was accepted: $fixture"
    fi
}

"$repo_root/usb-media/resolve-catalog" >/dev/null
"$verify" "$catalog" >/dev/null
"$render" "$catalog" > "$temporary/ventoy.json"
jq -e '
  (.control | map(has("VTOY_MENU_TIMEOUT")) | any | not) and
  ([.control[] | select(.VTOY_MENU_LANGUAGE == "ko_KR")] | length == 1) and
  (.menu_alias | length == 11)
' "$temporary/ventoy.json" >/dev/null || fail "rendered Ventoy contract is invalid"

jq '.entries[1].id = .entries[0].id' "$catalog" > "$temporary/duplicate-id.json"
expect_rejected "$temporary/duplicate-id.json"

jq '.entries[1].source.kind = "unknown-source"' "$catalog" > "$temporary/unknown-source.json"
expect_rejected "$temporary/unknown-source.json"

jq '.entries[1].destination = "../escape.iso"' "$catalog" > "$temporary/path-traversal.json"
expect_rejected "$temporary/path-traversal.json"

jq '.entries[1].source.sha256 = "not-a-digest"' "$catalog" > "$temporary/bad-digest.json"
expect_rejected "$temporary/bad-digest.json"

jq '.entries[1].profile_adapter = "shared-dangerous-default"' "$catalog" > "$temporary/unknown-adapter.json"
expect_rejected "$temporary/unknown-adapter.json"

jq '.entries += [{
  id: "example-live",
  group: "tools",
  version: "1.0",
  destination: "images/90-tools/example-live-1.0.iso",
  menu_alias: "Example Live 1.0",
  description_ko: "확장 계약 시험용 라이브 환경이다.",
  description_en: "Live environment used to test the extension contract.",
  boot_behavior: "live-environment",
  profile_adapter: "none",
  source: {
    kind: "locked-download",
    filename: "example-live-1.0.iso",
    url: "https://downloads.example.test/example-live-1.0.iso",
    sha256: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
}]' "$catalog" > "$temporary/extended.json"
"$verify" "$temporary/extended.json" >/dev/null
"$render" "$temporary/extended.json" |
    jq -e '.menu_alias[] | select(.image == "/images/90-tools/example-live-1.0.iso")' >/dev/null ||
    fail "declarative entry did not reach the rendered menu"

echo "media catalog simulations: passed"
