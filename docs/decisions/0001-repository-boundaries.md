# Decision 0001: Separate bootstrap, host state, and secrets

Status: accepted

## Decision

This repository owns day-0 installer media, first boot, and USB enrollment.
Ongoing host state remains in the host infrastructure repository. Long-lived
secrets remain in the encrypted principal secrets repository. Agent-facing MCP
services run in the management plane.

## Reason

Installer artifacts have different release, testing, storage, and destructive
safety concerns from continuously reconciled host configuration. Separating the
responsibilities keeps large generated images out of Git and prevents an agent
management service from becoming a dependency of the DNS appliances themselves.
