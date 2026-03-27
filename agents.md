# Agentic History Log (agents.md)

This document tracks the AI agent-assisted coding tasks performed in the **CK-X Repository**. It serves as restorable chat context for future agent sessions, documenting what was changed, where, and how.

## Project Context
**Project**: CK-X Simulator  
**Description**: A Docker-based Kubernetes certification practice environment with a web UI, remote desktop, and automated real-time grading.  
**Tech Stack**: Node.js (app), Nginx (proxy), Docker Compose, Kind/K3d clusters, Shell scripts (setup & validation).

### Repository Structure (Key Paths)
```
CK-X/
├── app/                          # Web application (UI + backend)
├── facilitator/
│   └── assets/exams/
│       ├── labs.json              # Registry of all available labs
│       └── ckad/
│           ├── 001/              # CKAD Lab 1
│           ├── 002/              # CKAD Lab 2
│           └── 003/              # CKAD Lab 3 (NEW - created in Conv 1)
│               ├── config.json       # Lab metadata (marks, thresholds)
│               ├── assessment.json   # Question definitions + verification mappings
│               ├── answers.md        # Reference answers for all questions
│               └── scripts/
│                   ├── setup/        # Environment bootstrap scripts (q<N>_setup.sh)
│                   └── validation/   # Grading scripts (q<N>_s<step>_<name>.sh)
├── docker-compose.yaml
├── compose-deploy.sh
└── scripts/                      # Installation scripts
```

### Conventions for Adding New Labs
- **Lab registration**: Add entry to `facilitator/assets/exams/labs.json`.
- **Config schema**: `config.json` defines `lab`, `workerNodes`, `answers` path, `questions` file, and score thresholds.
- **Assessment schema**: `assessment.json` contains a `questions[]` array; each question has `id`, `namespace`, `machineHostname`, `question` text, `concepts[]`, and `verification[]` steps.
- **Verification steps**: Each step has `verificationScriptFile`, `expectedOutput` (exit code, typically `"0"`), and `weightage`.
- **Script naming**: Setup scripts: `q<N>_setup.sh`. Validation scripts: `q<N>_s<step>_<description>.sh`.
- **Scripts must exit 0** on success, non-zero on failure.

---

## Conversation 1: Enhancing CKAD Exam Simulator
**Date**: 2026-03-27  
**Conversation ID**: `9f28d936-89b9-4c09-acbf-0dc6572d8c2b`

### Objective
Modernize the local CKAD exam simulator by resolving existing bugs in question scenarios and implementing a new, comprehensive lab (`ckad-003`) featuring 18 modern, high-difficulty questions matching the latest Kubernetes curriculum (v1.35+).

### Phase 1: Bug Fixes (CKAD-001 & CKAD-002)
Addressed 6 critical GitHub issues affecting existing test structures:

| Issue | Lab | Question | Fix Summary |
|-------|-----|----------|-------------|
| #43 & #56 | ckad-001 | Q10 | Changed to `mysql:8` for ARM support; injected literal `MYSQL_RANDOM_ROOT_PASSWORD` |
| #46 | ckad-001 | Q6 | Refactored to K8s 1.28+ native sidecar (`initContainers` + `restartPolicy: Always`) |
| #44 | ckad-001 | Q20 | Rewrote validation script to check log output instead of `/backup` file copies |
| #62 | ckad-002 | Q2 | Fixed nginx crash by mounting to `/var/log/app` instead of `/var/log` |
| #59 | ckad-002 | Q14 | Enforced FQDN `nslookup` loop for service resolution |

### Phase 2: Generating CKAD-003
Scraped Killercoda scenarios from 3 profiles (`ckad-exercises`, `omkar-shelke25`, `fc53-ckad`) to build new lab content.

**18 Questions Created** (all in `facilitator/assets/exams/ckad/003/`):

| Q# | Name | Key Concepts |
|----|------|-------------|
| 1 | The Sidecar Surgery | Native sidecars, initContainers |
| 2 | The Config Switchboard | ConfigMaps, env vars, volume mounts |
| 3 | The API Archaeologist | Manual API version migration, CronJobs |
| 4 | The Helm Expedition | Helm upgrade, rollback, history |
| 5 | The Kustomize Kaleidoscope | Kustomize overlays, patches, ConfigMapGenerator |
| 6 | The Blue-Green Bridge | Service label cutover, zero-downtime |
| 7 | The Canary Cage | Canary deployment, traffic splitting |
| 8 | The Fortress | SecurityContext, capabilities, readOnlyRootFilesystem |
| 9 | The Identity Crisis | ServiceAccounts, automountServiceAccountToken |
| 10 | The Traffic Director | Ingress path rewriting, ExternalName services |
| 11 | The Observatory | startupProbe, livenessProbe, readinessProbe |
| 12 | The Network Lockdown | NetworkPolicies, default deny, allow rules |
| 13 | The Persistent Bookshelf | PVC, dynamic provisioning, volume replacement |
| 14 | The Container Factory | Dockerfile, OCI image build, tar export |
| 15 | The Cross-Namespace Corridor | Cross-namespace DNS, FQDN |
| 16 | The Admission Gatekeeper | ResourceQuota, limits, requests |
| 17 | The Resilient Worker | CronJob, concurrencyPolicy, startingDeadlineSeconds |
| 18 | The Broken Node | Taints, tolerations, nodeAffinity |

**Artifacts Generated**: 11 setup scripts, 33 validation scripts, `config.json`, `assessment.json`, `answers.md`.  
**Integration**: Registered in `facilitator/assets/exams/labs.json` as 120-min, Hard difficulty.

---

## Conversation 2: CKAD-003 Accuracy Review & GitHub Bug Fixes
**Date**: 2026-03-27  
**Conversation ID**: `6f2ec184-654e-4922-85a6-91503669f3a8`

### Objective
Comprehensively review all 18 ckad-003 question scenarios for accuracy, fix all validation script issues, and resolve open GitHub bug-labeled issues.

### CKAD-003 Validation Script Fixes (13 scripts)

| Script | Fix |
|--------|-----|
| `q2_s2_configmap.sh` | Now validates `PORT=8080` and `THEME=dark` data values |
| `q2_s3_pod.sh` | Now uses jsonpath to verify env var name, configMapKeyRef key, and mount path |
| `q3_s1_manifest.sh` | Now explicitly rejects `v1beta1` (previously matched as substring) |
| `q4_s1_rollback.sh` | Now checks revision count ≥3 and latest entry is rollback |
| `q7_s1_canary.sh` | Now validates `app=frontend` label (critical for service routing), replicas, and image |
| `q8_s2_security.sh` | Now validates all 4 requirements: `runAsNonRoot`, `runAsUser=2000`, `readOnlyRootFilesystem`, `NET_RAW` drop |
| `q11_s2_probes.sh` | Now validates specific paths, ports, and periodSeconds for liveness/readiness |
| `q12_s1_deny.sh` | Now verifies both Ingress+Egress policyTypes exist |
| `q13_s1_pvc.sh` | Now uses `spec.resources.requests.storage` instead of `status.capacity` |
| `q16_s2_limits.sh` | Now extracts actual resource values via jsonpath |
| `q17_s2_constraints.sh` | Now validates both `concurrencyPolicy: Forbid` AND `startingDeadlineSeconds: 20` |
| `q18_s1_toleration.sh` | Now validates exact key=type, value=batch, effect=NoSchedule |
| `q18_s2_affinity.sh` | Now validates disktype=ssd in required nodeAffinity |

### CKAD-003 Question & Setup Fixes

| File | Fix |
|------|-----|
| `assessment.json` Q3 | Removed deprecated `kubectl convert`; now asks to manually edit apiVersion |
| `answers.md` Q3 | Changed answer from `kubectl convert` to `sed` command |
| `q15_setup.sh` | Added missing `q15-cross-ns` namespace creation |

### GitHub Bugs Resolved

| Issue | Lab | Fix |
|-------|-----|-----|
| [#65](https://github.com/sailor-sh/CK-X/issues/65) | CKA-002 Q6 | Added missing `volumeMounts` for emptyDir `html` volume in `answers.md` |
| [#42](https://github.com/sailor-sh/CK-X/issues/42) | CKA-002 Q16 | Changed `bitnami/kubectl:latest` → `bitnami/kubectl:1.28` in `answers.md` + `assessment.json` |

### GitHub Bugs Not Addressable in Code

| Issue | Reason |
|-------|--------|
| #67 | DNS resolution failure inside Docker — user network/firewall issue |
| #60 | Expired Docker Hub PAT — user credential issue |
| #28 | Nginx VNC-proxy WebSocket — nginx image rebuild required (infra) |
| #35 | CKS Q5 hostPath `/usr/bin` not in k3d — k3d cluster config limitation |
| #45 | CKA Q3 — minimal description, validation scripts appear correct |
| #51 | CKA Q9 ConfigMap — by design for teaching DNS config patterns |

---

## Pending / Future Work
- [ ] End-to-end testing of `ckad-003` in a live Kind cluster
- [ ] Fix CKS Q5 (#35) by adjusting k3d cluster config to mount `/usr/bin`
- [ ] Fix nginx VNC-proxy (#28) by updating nginx config
- [ ] Add more CKA/CKS labs
- [ ] CI/CD pipeline for validating scripts on PRs
- [ ] Question randomization across labs (deferred — architecture explored)
- [ ] Close resolved GitHub issues with PR references

---

## Conversation 3: CKAD-003 Coverage Expansion, Local Validation Docs, and Feature Branch
**Date**: 2026-03-27  
**Conversation ID**: `local-session-feat-ckad-003-local-validation`

### Objective
Close the remaining CKAD-003 curriculum gaps, document the local run and validation workflow, and prepare the repository for branch-based submission.

### Branch
- Created local feature branch: `feat-ckad-003-local-validation`

### CKAD-003 Additions

Added 3 new questions to `facilitator/assets/exams/ckad/003/assessment.json`:

| Q# | Name | Key Concepts |
|----|------|-------------|
| 19 | The Vault Transfer | Secrets, env vars |
| 20 | The Signal Hunt | `kubectl logs`, `kubectl get`, troubleshooting |
| 21 | The API Extension Forge | CRDs, custom resources, schema validation |

### CKAD-003 Supporting Changes

| File | Change |
|------|--------|
| `facilitator/assets/exams/ckad/003/answers.md` | Added solutions for Q19-Q21 |
| `facilitator/assets/exams/ckad/003/scripts/setup/q20_setup.sh` | Seeds crashing pod for log inspection |
| `facilitator/assets/exams/ckad/003/scripts/setup/q21_setup.sh` | Seeds namespace for CRD task |
| `facilitator/assets/exams/ckad/003/scripts/validation/q19_s1_secret.sh` | Validates decoded secret values |
| `facilitator/assets/exams/ckad/003/scripts/validation/q19_s2_pod.sh` | Validates secretKeyRef env wiring |
| `facilitator/assets/exams/ckad/003/scripts/validation/q20_s1_fatal.sh` | Validates captured fatal log output |
| `facilitator/assets/exams/ckad/003/scripts/validation/q20_s2_pods.sh` | Validates saved wide pod listing |
| `facilitator/assets/exams/ckad/003/scripts/validation/q21_s1_crd.sh` | Validates CRD group, kind, scope, schema, required fields |
| `facilitator/assets/exams/ckad/003/scripts/validation/q21_s2_resource.sh` | Validates custom resource contents |
| `facilitator/assets/exams/ckad/003/scripts/validation/q10_s1_ingress.sh` | Strengthened to validate regex ingress annotations, path, backend, and pathType |
| `facilitator/assets/exams/ckad/003/scripts/validation/q15_s1_fqdn.sh` | Now requires exact FQDN plus `:8080` |
| `facilitator/assets/exams/ckad/003/scripts/validation/q17_s1_cron.sh` | Now requires exact schedule `30 * * * *` |
| `facilitator/assets/exams/ckad/003/config.json` | Updated total marks and thresholds to match new weights |
| `facilitator/assets/exams/labs.json` | Updated CKAD-003 description to match actual scope |

### Documentation Updates

| File | Change |
|------|--------|
| `docs/development-setup.md` | Replaced placeholder clone path, added branch workflow, local lab validation loop, service-specific rebuild guidance, and push steps |
| `docs/how-to-add-new-labs.md` | Added local validation loop and push workflow for lab authors |

### Verification Performed

- `jq` validation passed for updated `ckad/003` JSON files
- `bash -n` passed for all `ckad/003` setup and validation scripts
- `assessment.json` now contains 21 questions
- Total verification weight now sums to 115

### Remaining Gap

- No live end-to-end simulator run was performed in this session; only static validation and documentation updates were completed
