# Lab 1 answers (this file is graded)

**Name:**  
**Date:**  

**Where to write:** put every answer on the **blank lines under** the label.  
Example: type your command under `Commands used:`, type WHOIS under `WHOIS:`. Do not type above the label.

```bash
python3 scripts/grade.py
python3 scripts/grade.py --show-parsed
```

---

## Ethics: 1 point

Tick the box below if you agree (put an x inside the brackets):

- [ ] I will only scan authorized lab targets (127.0.0.1 / localhost).

---

## Task 1 Footprinting : 2 points

Copy WHOIS / NS / A / AAAA from `artifacts/recon.txt`. Use **example.com only**.  
Command must include `recon_dns.sh` and `example.com`.

Commands used:



WHOIS:



NS records:



A record:



AAAA record:



---

## Task 2 Network scanning : 2 points

Fill **Service** and **Version** from the curl `Server:` lines (http + InsecureLab/0.1 and CampusBot/0.1).  
Command must include `scan_web.sh` and `127.0.0.1`.

Commands used:



| Port | Service | Version |
|------|---------|---------|
| 3000 |  |  |
| 8080 |  |  |

---

## Task 3 Web enumeration + Nikto: 3 points

Look with **curl** and the **browser**, then run the scripts.  
Add 3 paths under `STUDENT_PATHS` in `lab/wordlist.txt`, then re-run `enum_web.sh`.  
Copy the main commands you ran under **Commands used**.

Commands used:



WEB_FLAG:



Missing header 1:



Missing header 2:



---

## Task 4  CampusBot / OWASP LLM : 2 points

You may try the browser on port 8080, but **points require** `./scripts/chat_ai.sh "..."` so `artifacts/chat.txt` contains the flag.
OWASP: https://owasp.org/www-project-top-10-for-large-language-model-applications/ — this lab is **LLM01 Prompt Injection** (https://genai.owasp.org/llmrisk/llm01-prompt-injection/).

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
