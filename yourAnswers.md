# Network Applications & Security - Lab Report: Reconnaissance & Vulnerability Scanning Lab

Your Full Name: ___________________  
Date: ___________________
---

## 1️⃣ Domain Footprinting – recon_dns.sh (3 pts)

**List commands that you have  used:**





**Findings (summary):**

- WHOIS:

- NS Records:

- A Record:

- AAAA Record:


**Write in your own words 2–3 sentences on what these records reveal.**






---

## 2️⃣ Network Scanning – scan_web.sh (4 pts)
**List commands that you have  used:**


**Findings table:**

The following table is an example. You are required to replace the port number. service and versions with your own findings. 

| Port | Service | Version (if detected) |
|------|---------|------------------------|
| 80   | HTTP    | Apache/2.4.54          |
| 443  | HTTPS   | nginx/1.22             |
| 3000 | WebApp  | Node.js/Express        |
| 445  | SMB     | Samba 4.15             |





## 3️⃣ SMB Enumeration – enumerate_smb.sh (4 pts)
**List commands that you have  used:**


**Findings :**

**Findings:**
- Discovered share(s):  
- File(s) listed in the share:  

**File contents (example: readme.txt):**

**Why having a public/guest-accessible share be a security issue?** Answer a couple of point sin your own words. 




## 4️⃣ Web Vulnerability Scanning – vuln_scan.sh (4 pts)

**List commands that you have  used:**




**Findings (at least two issues):**
1. <first finding here>  
   - Why it matters: <short explanation>  

2. <second finding here>  
   - Why it matters: <short explanation>  

**Explanation (summary):**  
Write 1–2 sentences about what these results show and why running a web vulnerability scan is useful in your own words.  


















## Targets & Scope

- **Domain (footprinting):** example.com (authorized public training domain)
- **Host (network scan):** 127.0.0.1 (local demo) or instructor-provided test VM
- **Web App (nikto):** http://127.0.0.1:8080 (test only)
- **SMB Target (optional):** 127.0.0.1 or lab VM (guest/anonymous only)


## Tools & Commands 

- `./scripts/recon_dns.sh example.com`
- `./scripts/scan_web.sh 127.0.0.1`
- `./scripts/enumerate_smb.sh 127.0.0.1`
- `./scripts/vuln_scan.sh http://127.0.0.1:8080`

## Findings (Highlights) 

### DNS / WHOIS
- **Registrar/Vitals (truncated):** WHOIS returned registrar and nameservers for `example.com`.
- **A Records:** Resolved to public training IP (varies by resolver).
- **NS Records:** Authoritative nameservers identified.

### Network Scan
- **Open Ports (top 100 scan):** 
  - (Sample) 22/tcp (ssh) — Open, OpenSSH banner detected
  - (Sample) 80/tcp (http) — Open, Apache/Nginx banner (if present)
- **OS Guess:** Nmap fingerprinting produced a tentative OS match .

### SMB Enumeration (if target available)
- **NetBIOS:** Hostname discovered via `nmblookup` (if SMB stack present).
- **Shares (guest):** No guest-accessible shares found in sample run.
- **RPC Info:** `srvinfo` returned basic host info (if allowed).


### Web Vulnerability Scan (Nikto)
- **Headers:** Identified common headers; server banner may reveal version.
- **Potential Issues:** Example findings like directory indexing, outdated server modules, or default files (dependent on test service).

> Note: Nikto produces many *informational* items; validate before treating as vulnerabilities.