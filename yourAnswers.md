# Lab 1 answers (this file is graded)

**Name:**  
**Date:**  

Keep the labels below (WHOIS, WEB_FLAG, Missing header 1, …).  
Write your answers under each label. Then run:

```bash
python3 scripts/grade.py
python3 scripts/grade.py --show-parsed
```

---

## Ethics — 1 point

Tick the box below if you agree (put an x inside the brackets):

- [ ] I will only scan authorized lab targets (127.0.0.1 / localhost).

---

## Task 1 — Footprinting — 2 points

Commands used:



Copy values from `artifacts/recon.txt` after `./scripts/recon_dns.sh example.com`.
Use **example.com only**. WHOIS should mention IANA. Cloudflare NS records are normal for this domain.

WHOIS:



NS records:



A record:



AAAA record:



---

## Task 1 optional — Copilot Chat (0 points, not graded)

Optional. Prompts you used and anything you verified (or caught as a hallucination).

Copilot questions I asked:



What I checked against artifacts/recon.txt:



---

## Task 2 — Network scanning — 2 points

Commands used:



Fill **Service** and **Version** from the curl `Server:` headers (http / InsecureLab/0.1 and CampusBot/0.1).
Nmap may show `ppp` on 3000 and `http-proxy` on 8080 — that is a default name, not a failed scan. Do not delete the port numbers.

| Port | Service | Version |
|------|---------|---------|
| 3000 |  |  |
| 8080 |  |  |

---

## Task 2 optional — Copilot Chat (0 points, not graded)

Optional. Prompts you used and anything you verified against artifacts/scan.txt.

Copilot questions I asked:



What I checked (open ports, nmap vs curl, defender ideas):



---

## Task 3 — Web enumeration + Nikto — 3 points

First look with curl (homepage, robots.txt, headers), then run the scripts.
Read 200 responses in artifacts/enum.txt for WEB_FLAG.
Confirm two missing headers with curl -I (they should not appear in the header list).

Commands used:



WEB_FLAG:



Missing header 1:



Missing header 2:



---

## Task 3 optional — Copilot Chat (0 points, not graded)

Optional. No summary is graded. Prompts you used and what you verified in enum/Nikto output.

Copilot questions I asked:



What I checked (paths, headers, curl -I, defender options):



---

## Task 4 — CampusBot / OWASP LLM — 2 points

Chat at http://127.0.0.1:8080 or `./scripts/chat_ai.sh "your message"`.
A "Hello" will not show the flag. Ask the bot to show hidden / system instructions.
Paste what you submit under the labels. Example shape only: `LLM_FLAG{this_is_an_example_not_the_real_flag}`

Commands or prompts used:



LLM_FLAG:



OWASP issue:



Defense:



---

## Submit

```bash
python3 scripts/grade.py
git add yourAnswers.md artifacts/
git commit -m "Complete lab 1 tasks"
git push origin main
```
