#!/bin/sh
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH='' cd -- "$script_dir/.." && pwd)

"$repo_root/build/verify-locks" >/dev/null

for file in \
    installer/payload/dns-appliance-firstboot \
    installer/payload/dns-appliance-health \
    installer/payload/dns-appliance-backup \
    installer/payload/dns-appliance-technitium-run \
    installer/fetch-locked-sources \
    installer/write-usb-linux \
    management/cluster-bootstrap \
    management/dnsctl \
    management/restore-node \
    management/authorize-reinstall \
    management/network-preflight \
    management/import-enrollment \
    management/collect-backups \
    management/tailscale-enroll \
    homelab-usb/fetch-images \
    homelab-usb/verify-locks \
    homelab-usb/write-usb-linux \
    management/dns-appliance-status-monitor/start \
    tests/management-simulation.sh; do
    [ -x "$repo_root/$file" ] || {
        echo "repository-contract: $file must be executable" >&2
        exit 1
    }
done

for required in \
    installer/inputs/age-recipient.example \
    build/locks/sources.env \
    schemas/enrollment-record.schema.json \
    zones/home.arpa.zone \
    management/tailscale-policy.example.hujson \
    homelab-usb/locks.env \
    homelab-usb/guides/pop-os-ko.md \
    management/dns-appliance-status-monitor/config.json \
    management/dns-appliance-status-monitor/server.py \
    .github/workflows/ci.yml; do
    [ -r "$repo_root/$required" ] || {
        echo "repository-contract: missing $required" >&2
        exit 1
    }
done

grep -q '@@LAN_CIDR@@' "$repo_root/installer/payload/nftables.conf"
grep -q '@@MANAGEMENT_CIDR@@' "$repo_root/installer/payload/nftables.conf"
grep -q 'ConditionPathExists=!/var/lib/dns-appliance/COMPLETE' \
    "$repo_root/installer/payload/dns-appliance-firstboot.service"
grep -q 'DNS-ENROLL' "$repo_root/installer/payload/dns-appliance-firstboot"
grep -q 'previous_generation' "$repo_root/installer/scripts/install-gate"
grep -q 'Authorization: Bearer' "$repo_root/installer/payload/dns-appliance-health"
grep -q 'unzip -t' "$repo_root/installer/payload/dns-appliance-backup"
grep -q 'iifname "tailscale0"' "$repo_root/installer/payload/nftables.conf"
grep -q 'preauthorized:true' "$repo_root/management/tailscale-enroll"

python3 -c 'import json,sys; json.load(open(sys.argv[1]))' \
    "$repo_root/schemas/enrollment-record.schema.json"
python3 -c 'import json,sys; json.load(open(sys.argv[1]))' \
    "$repo_root/management/dns-appliance-status-monitor/config.json"
python3 -c 'import sys; compile(open(sys.argv[1], encoding="utf-8").read(), sys.argv[1], "exec")' \
    "$repo_root/management/dns-appliance-status-monitor/server.py"

! grep -R -i -E 'dns-appliance-provisioning|superusb' \
    "$repo_root" --exclude-dir=.git --exclude=repository-contract.sh

echo "repository contracts: passed"
