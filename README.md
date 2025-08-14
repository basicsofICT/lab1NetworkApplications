# Network Applications & Security - Lab 1: Reconnaissance & Vulnerability Scanning Lab

In this lab, you will work through foundational recon and vulnerability scanning entirely in **GitHub Codespaces**.  

All tools are preinstalled by the devcontainer. 

---

## Objectives
- Gather public information (footprinting)
- Scan for open ports/services
- Enumerate basic SMB info (where available)
- Run a lightweight web vulnerability scan

---

## Environment (auto-provisioned)
Tools available in this Codespace:
- `whois`, `dig` (`dnsutils`), `nslookup`
- `nmap`
- `nikto`
- `smbclient`, `rpcclient`, `nmblookup` (for SMB enumeration)
- `python3`

> All installed by the devcontainer’s `postCreateCommand`.

---

## Ethics & Legal Notes

- Test only authorized lab targets.
- **Only scan authorized targets. Never test external domains/IPs without explicit written permission.**

- Do not run any scan against external or production systems.

- Findings are used only for learning purposes. 

## Lab Tasks

### 1) Footprinting a Domain: 
**Goal: Identify registrant info (WHOIS), name servers, A/AAAA records.**

```bash
./scripts/recon_dns.sh example.com
```

### 2) Network Scanning 
**Goal: Identify open ports/services and probe HTTP(S).**

```bash
./scripts/scan_web.sh <target-host-or-ip>
```
>> ***Use only authorized/test targets. For practice, use a host you own***

### 3) SMB Enumeration (if an SMB target is authorized & reachable) 
**Goal: Attempt guest/anonymous listing of shares; gather basic host info.**

```bash
./scripts/enumerate_smb.sh <target-ip>  
```

### 4) Web Vulnerability Scanning (basic)
**Goal: Perform a light nikto scan against an authorized test web app.**

```bash
./scripts/vuln_scan.sh http://127.0.0.1:8080 
```

### Report Template

***Fill out report.md as you do these tasks:***

