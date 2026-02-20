# 🔐 Kasten Executor Encryption Finder

------------------------------------------------------------------------

## 📌 Overview

**Kasten Executor Encryption Finder** is a lightweight Bash tool that
scans all Kasten executor pods and extracts the **actual encryption
algorithm** used by the datapath for a given namespace (`SubjectRef`).

It is designed for:

-   🔎 Fast troubleshooting\
-   🔐 Encryption validation\
-   📊 Security audits\

------------------------------------------------------------------------

## ✨ Key Features

✅ Scans **all executor pods automatically**\
✅ Handles **multi-container pods**\
✅ Includes **previous logs after restarts**\
✅ Extracts real datapath encryption\
✅ Clean **table output**\
✅ Supports **latest-only mode**\
✅ Safe read-only operation\
✅ Works in homelab and enterprise clusters

------------------------------------------------------------------------

## 🏗️ Architecture

``` mermaid
flowchart LR
    A[kubectl logs] --> B[Executor Pods]
    B --> C[Log Parsing]
    C --> D[Field Extraction]
    D --> E[Formatted Table Output]
```

------------------------------------------------------------------------

## 📋 Requirements

### Mandatory

-   Kubernetes cluster
-   Kasten K10 installed
-   `kubectl` configured
-   Bash shell
-   `awk`

### Recommended

-   Adequate executor log retention
-   RBAC allowing log access

------------------------------------------------------------------------

## 🚀 Quick Start

### 1️⃣ Clone or copy the script

``` bash
chmod +x find-encryption-table.sh
```

### 2️⃣ Run

``` bash
./find-encryption-table.sh <targetted_namespace>
```

Or

``` bash
./find-encryption-table.sh <targetted_namespace> 30000 lastest
```

------------------------------------------------------------------------

## ⚙️ Usage

``` bash
./find-encryption-table.sh <targetted_namespace> [k10-namespace] [tail-lines] [mode]
```

### Parameters

  Parameter       Description                    Default
  --------------- ------------------------------ --------------
  targetted_namespace      Workload namespace to search   **required**
  k10 namespace   Kasten namespace               `kasten-io`
  tail lines      Log depth per pod              `300000`
  mode            `all` or `latest`              `all`

------------------------------------------------------------------------

## 📊 Output Example

    NAMESPACE           TIME                                ENCRYPTION
    ---------           ----                                ----------
    targetted_namespace 2026-02-20T00:01:15.558379961Z     AES256-GCM-HMAC-SHA256

------------------------------------------------------------------------

## 🔍 Examples

### Show all matches

``` bash
./find-encryption-table.sh pihole
```

### Show latest only

``` bash
./find-encryption-table.sh pihole kasten-io 300000 latest
```

### Deep log inspection

``` bash
./find-encryption-table.sh pihole kasten-io 800000
```

------------------------------------------------------------------------

## 🧪 Troubleshooting

### ❌ No results returned

Check:

-   Executor pods exist
-   Logs are recent enough
-   SubjectRef spelling is correct
-   Pods have not rotated logs

Quick debug:

``` bash
kubectl -n kasten-io get pods | grep executor
kubectl -n kasten-io logs <executor-pod> --all-containers | grep SubjectRef
```


