# Network Applications & Security - Lab 1: Reconnaissance & Vulnerability Scanning Lab

In this lab, you will work through foundational recon and vulnerability scanning entirely in **GitHub Codespaces**. 

This lab gives you a **safe environment** to practice the first steps of penetration testing: reconnaissance, scanning and basic enumeration.  

Everything runs in your **GitHub Codespace**, with all tools and test services pre-installed. 

⚠️ **Important:** Only scan the containers in this lab or domains you personally own. You should never run these scripts against unauthorized systems.

---

## Objectives

1. **Understanding Information Disclosure**

- Learn how basic records like WHOIS and DNS expose details about ownership, hosting, and infrastructure.

- Recognize why minimizing unnecessary exposure is important for real-world organizations.

2. **Network & Service Discovery**

- Use port scanning to identify which services are open and reachable.

- Practice distinguishing between a host is up vs. host is offering a vulnerable service.

3. **Service Enumeration**

- Enumerate SMB shares to see how misconfigurations (e.g., guest access) can lead to information leaks.

- Understand the role of enumeration as the “bridge” between simple scanning and deeper exploitation.

4. **Web Application Footprinting**

- Run a lightweight vulnerability scan (Nikto) to discover common misconfigurations and outdated software.


5. **Safe Lab Practice**

- Get to know how to build your own testing playground (with Docker & Codespaces).

- Practice scanning responsibly, without impacting external systems.

>> 👉 In short: you’re learning how attackers see networks from the outside, but in a controlled lab that lets you safely practice professional penetration testing methodology.
---

## Ethics & Legal Notes

- Test only authorized lab targets.
- **Only scan authorized targets. Never test external domains/IPs without explicit written permission.**

- Do not run any scan against external or production systems.

- Findings are used only for learning purposes. 

---

## Getting Started 

1. **Open this repo in GitHub Codespaces.**  
   All tools and services will be installed automatically (thanks to `.devcontainer/postCreateCommand`).  
   - Services started for you:
     - Juice Shop (webapp) → `http://127.0.0.1:3000`
     - Httpbin (test HTTP service) → `http://127.0.0.1:8080`
     - Samba SMB server → `smb://127.0.0.1/public`

2. **Check that services are running:**
   ```bash
   docker ps
   # You should see juice-shop, httpbin and samba.
   ```
---

## Services in the Lab

- **Juice Shop (3000)**
    - Intentionally vulnerable Node.js app. → Target for web vulnerability scanning.

- **Httpbin (8080)**
    - Simple HTTP echo server. → Target for port/service scanning.

- **Samba SMB (445)**
    - Lightweight SMB server with a public share containing readme.txt. → Target for enumeration practice.

## Lab Tasks (Total: 15 Points)

It’s important that all the scripts in the scripts/ folder are executable, otherwise you won’t be able to run them directly.

**You only need to do this once (the first time you set up the lab):**

```bash
chmod +x scripts/*.sh
```


### 1) Footprinting a Domain: recon_dns.sh (3 pts)
**Goal: Identify registrant info (WHOIS), name servers, A/AAAA records.**

```bash
./scripts/recon_dns.sh example.com
```
- Run against example.com.

- Record WHOIS and DNS A/AAAA/NS info.

- ***Deliverable: 2–3 sentences on what these records reveal.***



### 2) Network Scanning – scan_web.sh (4 pts)
**Goal: Identify open ports/services and probe HTTP(S).**

```bash
./scripts/scan_web.sh <target-host-or-ip>
```
>> ***Use only authorized/test targets. For practice, use a host you own***

- Run against 127.0.0.1.

- Identify open ports and detected services.

- ***Deliverable: A table like Port | Service.***

### 3)SMB Enumeration – enumerate_smb.sh (4 pts)
**Goal: Attempt guest/anonymous listing of shares; gather basic host info.**

```bash
./scripts/enumerate_smb.sh <target-ip>  
```
- Enumerate the public share.

- Download and read readme.txt.

- ***Deliverable: Output showing the file + its contents.***

### 4) Web Vulnerability Scanning (basic) (4 pts)
**Goal: Perform a light nikto scan against an authorized test web app.**

```bash
./scripts/vuln_scan.sh http://127.0.0.1:8080 
```

- Run against http://127.0.0.1:3000
- Review the Nikto output.
- Identify at least two issues flagged by Nikto.

- ***Deliverable: Each issue + a one-line explanation.***

### Report Template

***Fill out report.md as you do these tasks:***


## Lab project directory structure
```bash
security-lab/
├─ .devcontainer/
│  ├─ devcontainer.json      # VS Code Codespace config
│  └─ Dockerfile             # Base image setup
│
├─ docker-compose.yml        # Defines webapp, httpbin and smb services
├─ shares/                   # Local test files for the SMB container
│  └─ public/
│     └─ readme.txt          # A harmless test file
│
├─ scripts/                  # Recon & enumeration scripts
│  ├─ recon_dns.sh           # WHOIS + DNS lookups
│  ├─ scan_web.sh            # Port/service scanning + HTTP probing
│  ├─ enumerate_smb.sh       # SMB share enumeration
│  └─ vuln_scan.sh           # Local-only Nikto scan
│
├─ README.md                 # Documentation (tasks, learning goals, usage)
```