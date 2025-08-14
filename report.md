# Network Applications & Security - Lab Report: Reconnaissance & Vulnerability Scanning Lab

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