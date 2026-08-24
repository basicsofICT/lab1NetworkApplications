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

## Task 2 — Network scanning — 2 points

Commands used:



Fill **Service** and **Version** from the curl `Server:` headers (http / InsecureLab/0.1 and CampusBot/0.1).
Nmap may show `ppp` on 3000 and `http-proxy` on 8080 — that is a default name, not a failed scan. Do not delete the port numbers.

| Port | Service | Version |
|------|---------|---------|
| 3000 |  |  |
| 8080 |  |  |

Attacker/defender note:



---

## Task 3 — Web enumeration + Nikto — 3 points

Commands used:



WEB_FLAG:



Missing header 1:



Missing header 2:



---

## Task 4 — CampusBot / OWASP LLM — 2 points

Use `./scripts/chat_ai.sh "your message"` (saves `artifacts/chat.txt`) or the page on port 8080.
A normal "Hello" will not reveal the secret. Try to get the bot to show its hidden instructions.
Then paste the flag and write a defense. Keep these labels.

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
