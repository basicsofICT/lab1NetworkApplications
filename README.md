# Network Applications & Security - Lab 1: Reconnaissance & Vulnerability Scanning Lab

This lab gives you a **safe environment** to practice the first steps of penetration testing: reconnaissance, scanning and basic web assessment.  

Everything runs in your **GitHub Codespace**, with tools pre-installed and two local web services started automatically.

⚠️ **Important:** Only scan the containers in this lab or domains you personally own. You should never run these scripts against unauthorized systems.

---

## Objectives

- **Information disclosure from DNS/WHOIS:** How public records reveal ownership and infrastructure details.

- **Network & service discovery:** Using port scans and lightweight probes (HTTP headers/banners) to map reachable services.

- **Basic web assessment:** Interpreting scanner output (e.g., missing headers, default listings). 


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
   All tools and services will be installed automatically 
   - Services started for you:
     - HTTP on 3000 → `http://127.0.0.1:3000`
     - HTTP on 8080 → `http://127.0.0.1:8080`

2. **Check that services are running:**
```bash
    curl -I http://127.0.0.1:3000
    curl -I http://127.0.0.1:8080
   # You should see HTTP responses for both.
   ```
---

## Services in the Lab

- **HTTP on 3000**
    - Simple Python http.server serving your repo root.
- **HTTP on 8080**
    - Another instance of http.server.

## Lab Tasks (Total: 10 Points)

It’s important that all the scripts in the scripts/ folder are executable, otherwise you won’t be able to run them directly.

**You only need to do this once (the first time you set up the lab):**

```bash
chmod +x scripts/*.sh
```


### 1) Footprinting a Domain: recon_dns.sh (2 pts)
**Goal: Identify registrant info (WHOIS), name servers, A/AAAA records.**

```bash
./scripts/recon_dns.sh example.com
```
- Run against example.com.

- Record WHOIS and DNS A/AAAA/NS info.

- ***Deliverable: 2–3 sentences on what these records reveal.***



### 2) Network Scanning – scan_web.sh (3 pts)
**Goal: Identify open ports/services and probe HTTP(S).**

```bash
sudo ./scripts/scan_web.sh <target-host-or-ip>
```
>> ***Use only authorized/test targets. For practice, use a host you own or the one in this codespace environment***

- Run against 127.0.0.1

- Identify open ports and detected services.

- ***Deliverable: A table like Port | Service and a brief explanation of what that means for an attacker/defender.***

### 3) Web Vulnerability Scanning (basic) (3 pts)
**Goal: Perform a light nikto scan against an authorized test web app.**

```bash
sudo ./scripts/vuln_scan.sh http://127.0.0.1:3000
sudo ./scripts/vuln_scan.sh http://127.0.0.1:8080
```

- Run against http://127.0.0.1:3000
- Review the Nikto output.
- Extract at least two observations (e.g., missing security headers like X-Frame-Options, Content-Security-Policy, etc.)
- Identify at least two issues flagged by Nikto.

- ***Deliverable: Each issue + a one-line explanation.***

### Report Template

***Fill out yourAnswers.md as you do these tasks:***

