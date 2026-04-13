# B2B Order Portal - Salesforce

Salesforce application for managing B2B orders via an Experience Cloud portal.

## Stack
- Salesforce DX
- Apex (Controller / Service / Domain / Selector)
- Lightning Web Components (LWC)
- Experience Cloud (LWR)

## Setup

```bash
sf org login web --alias devhub --set-default-dev-hub
sf org create scratch --definition-file config/project-scratch-def.json --alias scratch1 --target-dev-hub devhub
sf project deploy start --target-org scratch1