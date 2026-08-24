#!/usr/bin/env python3
"""Autograder for Lab 1 (10 points). Reads yourAnswers.md + artifacts/.

Students fill ordinary markdown. Do not use answers.json.

Usage:
  python3 scripts/grade.py              # scorecard
  python3 scripts/grade.py --show-parsed
  python3 scripts/grade.py --json
  python3 scripts/grade.py --github-summary
  python3 scripts/grade.py --check ethics
  python3 scripts/grade.py --list-checks
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]
ANSWERS_MD = ROOT / "yourAnswers.md"
ART = ROOT / "artifacts"

WEB_FLAG_SHA256 = "f88e69d8b26582a8f9904e72a86b658758cc3b38897aa1abe1380e3dafb24267"
LLM_FLAG_SHA256 = "a31d604c62cd62b696974279b8593dd73208a830e0d10abe8b3b0486efe86336"

EXPECTED_HEADERS = (
    "x-frame-options",
    "content-security-policy",
    "strict-transport-security",
    "x-content-type-options",
)

OWASP_PATTERNS = (
    r"prompt\s*injection",
    r"llm0\s*1",
    r"owasp\s*llm",
    r"sensitive\s*information\s*disclosure",
    r"system\s*prompt",
)

PLACEHOLDERS = {
    "",
    "____",
    "...",
    "---",
    "paste here",
    "write here",
    "(write here)",
    "your answer",
    "fill in",
    "(fill in)",
    "n/a",
    "-",
}

# Labels in yourAnswers.md — keep these in the template; students write below them.
FIELDS = [
    "WHOIS",
    "NS records",
    "A record",
    "AAAA record",
    "Attacker/defender note",
    "WEB_FLAG",
    "Missing header 1",
    "Missing header 2",
    "LLM_FLAG",
    "OWASP issue",
    "Defense",
]


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.strip().encode("utf-8")).hexdigest()


def is_placeholder(value: str) -> bool:
    return value.strip().lower().strip("`") in PLACEHOLDERS


def clean_value(value: str) -> str:
    text = value.replace("\r\n", "\n").strip()
    text = re.sub(r"^```[a-zA-Z0-9]*\n?", "", text)
    text = re.sub(r"\n```$", "", text)
    text = text.strip().strip("`").strip()
    text = re.sub(r"\n---+\s*$", "", text).strip()
    if is_placeholder(text):
        return ""
    return text


def field_pattern(label: str) -> str:
    # [ \t] only — do not use \\s, or blank lines get swallowed and the next label is captured.
    return (
        r"(?im)^[ \t]*(?:#{1,6}[ \t]*)?(?:\*{0,2}|_{0,2})"
        + re.escape(label)
        + r"(?:\*{0,2}|_{0,2})?[ \t]*:?[ \t]*(.*)$"
    )


def extract_field(md: str, label: str) -> str:
    matches = list(re.finditer(field_pattern(label), md))
    if not matches:
        return ""
    start = matches[0]
    after = start.group(1) or ""
    rest = md[start.end() :]
    stop = len(rest)
    for other in FIELDS:
        if other.lower() == label.lower():
            continue
        m = re.search(field_pattern(other), rest)
        if m:
            stop = min(stop, m.start())
    heading = re.search(r"(?m)^##\s+", rest)
    if heading:
        stop = min(stop, heading.start())
    body = after + "\n" + rest[:stop]
    return clean_value(body)


def extract_flag(md: str, name: str) -> str:
    labeled = extract_field(md, name)
    found = re.search(rf"{re.escape(name)}\{{[^}}]+\}}", labeled or md, re.I)
    return found.group(0).strip() if found else ""


def parse_ports(md: str) -> dict[int, dict[str, str]]:
    found: dict[int, dict[str, str]] = {}
    row = re.compile(
        r"\|\s*(3000|8080)\s*\|\s*([^|\n]*)\|\s*([^|\n]*)\|",
        re.I,
    )
    for m in row.finditer(md):
        service = clean_value(m.group(2))
        version = clean_value(m.group(3))
        found[int(m.group(1))] = {"service": service, "version": version}
    return found


def load_answers() -> dict[str, Any]:
    if not ANSWERS_MD.exists():
        return {"_error": "yourAnswers.md is missing."}
    md = ANSWERS_MD.read_text(encoding="utf-8", errors="replace")
    ethics_part = re.split(r"(?im)^##\s+Task\s+1\b", md, maxsplit=1)[0]
    ethics = bool(re.search(r"-\s*\[(?:x|X|✓)\]", ethics_part))

    headers = []
    for label in ("Missing header 1", "Missing header 2"):
        value = extract_field(md, label)
        if value:
            headers.append(re.split(r"[,;\n]", value)[0].strip())

    ports = parse_ports(md)
    return {
        "ethics_acknowledged": ethics,
        "recon": {
            "whois": extract_field(md, "WHOIS"),
            "ns": extract_field(md, "NS records"),
            "a": extract_field(md, "A record"),
            "aaaa": extract_field(md, "AAAA record"),
        },
        "scan": {
            "ports": [
                {"port": port, **found} for port, found in sorted(ports.items())
            ],
            "note": extract_field(md, "Attacker/defender note"),
        },
        "web": {
            "web_flag": extract_flag(md, "WEB_FLAG"),
            "missing_headers": headers,
        },
        "ai": {
            "llm_flag": extract_flag(md, "LLM_FLAG"),
            "owasp_issue": extract_field(md, "OWASP issue"),
            "defense": extract_field(md, "Defense"),
        },
        "_source": "yourAnswers.md",
    }


def read_artifact(*names: str) -> str:
    for name in names:
        path = ART / name
        if path.exists():
            return path.read_text(encoding="utf-8", errors="replace")
    return ""


def nonempty(value: Any, min_len: int = 1) -> bool:
    return isinstance(value, str) and len(value.strip()) >= min_len and not is_placeholder(value)


def check_ethics(ans: dict[str, Any]) -> tuple[bool, str]:
    if ans.get("ethics_acknowledged") is True:
        return True, "Ethics box is checked."
    return False, "In yourAnswers.md, tick the ethics box: change [ ] to [x]."


def check_recon_artifact(_ans: dict[str, Any]) -> tuple[bool, str]:
    text = read_artifact("recon.txt")
    if not text.strip():
        return False, "Missing artifacts/recon.txt. Run ./scripts/recon_dns.sh example.com"
    is_example = bool(re.search(r"example\.com", text, re.I))
    is_iana = bool(
        re.search(
            r"Internet Assigned Numbers Authority|RESERVED-Internet Assigned Numbers Authority|whois\.iana\.org",
            text,
            re.I,
        )
    )
    has_ns = bool(re.search(r"\sIN\s+NS\s+", text)) or bool(re.search(r"Name Server:", text, re.I))
    has_a = bool(re.search(r"\sIN\s+A\s+", text)) or bool(re.search(r"\sIN\s+AAAA\s+", text))
    if is_example and is_iana and has_ns and has_a:
        return True, "Recon artifact contains example.com WHOIS (IANA) plus NS and A/AAAA records."
    missing = []
    if not is_example:
        missing.append("example.com")
    if not is_iana:
        missing.append("IANA WHOIS (Internet Assigned Numbers Authority)")
    if not has_ns:
        missing.append("NS records")
    if not has_a:
        missing.append("A or AAAA records")
    return False, "artifacts/recon.txt is missing: " + ", ".join(missing) + ". Run ./scripts/recon_dns.sh example.com"


def check_recon_answers(ans: dict[str, Any]) -> tuple[bool, str]:
    recon = ans.get("recon") or {}
    problems = []
    if not nonempty(recon.get("whois"), 8):
        problems.append("WHOIS is too short (copy a few lines from the whois output, not only the domain name)")
    if not nonempty(recon.get("ns"), 4):
        problems.append("NS records are empty")
    if not (nonempty(recon.get("a"), 4) or nonempty(recon.get("aaaa"), 4)):
        problems.append("A or AAAA record is empty")
    if problems:
        return False, problems[0] if len(problems) == 1 else " | ".join(problems)
    return True, "Footprinting answers in yourAnswers.md are filled in."


def check_scan_artifact(_ans: dict[str, Any]) -> tuple[bool, str]:
    text = read_artifact("scan.txt")
    if not text.strip():
        return False, "Missing artifacts/scan.txt. Run ./scripts/scan_web.sh 127.0.0.1"
    has_3000 = bool(re.search(r"\b3000\b", text))
    has_8080 = bool(re.search(r"\b8080\b", text))
    if has_3000 and has_8080:
        return True, "Scan artifact mentions lab ports 3000 and 8080."
    return False, "artifacts/scan.txt must show ports 3000 and 8080."


def check_scan_answers(ans: dict[str, Any]) -> tuple[bool, str]:
    scan = ans.get("scan") or {}
    by_port = {}
    for row in scan.get("ports") or []:
        try:
            by_port[int(row.get("port"))] = row
        except (TypeError, ValueError):
            continue
    p3000 = by_port.get(3000) or {}
    p8080 = by_port.get(8080) or {}
    services_ok = nonempty(p3000.get("service"), 2) and nonempty(p8080.get("service"), 2)
    if services_ok and nonempty(scan.get("note"), 40):
        return True, "Port table has services for 3000 and 8080, plus a note."
    return False, "In the port table, fill Service for 3000 and 8080, and write Attacker/defender note (40+ characters)."


def check_web_flag(ans: dict[str, Any]) -> tuple[bool, str]:
    flag = str((ans.get("web") or {}).get("web_flag") or "")
    if sha256_text(flag) != WEB_FLAG_SHA256:
        return False, "WEB_FLAG in yourAnswers.md is missing or incorrect."
    evidence = read_artifact("enum.txt")
    if "WEB_FLAG{" not in evidence and "/hidden/" not in evidence:
        return False, "Put the enumeration output in artifacts/enum.txt (run ./scripts/enum_web.sh)."
    return True, "Web flag is correct and enumeration evidence is present."


def check_headers(ans: dict[str, Any]) -> tuple[bool, str]:
    headers = (ans.get("web") or {}).get("missing_headers") or []
    named = {str(h).strip().lower() for h in headers}
    matches = [h for h in EXPECTED_HEADERS if h in named]
    if len(matches) >= 2:
        return True, f"Identified missing headers: {', '.join(matches[:4])}."
    return False, "Fill Missing header 1 and 2 in yourAnswers.md (two different security header names)."


def check_nikto(_ans: dict[str, Any]) -> tuple[bool, str]:
    text = read_artifact("nikto.txt", "nikto-3000.txt", "vuln.txt")
    if not text.strip():
        return False, "Missing artifacts/nikto.txt. Run ./scripts/vuln_scan.sh http://127.0.0.1:3000"
    if re.search(r"nikto|target ip|header", text, re.I):
        return True, "Nikto artifact is present."
    return False, "artifacts/nikto.txt does not look like Nikto output."


def check_llm_flag(ans: dict[str, Any]) -> tuple[bool, str]:
    flag = str((ans.get("ai") or {}).get("llm_flag") or "")
    if sha256_text(flag) != LLM_FLAG_SHA256:
        return False, "LLM_FLAG in yourAnswers.md is missing or incorrect."
    evidence = read_artifact("chat.txt")
    if "LLM_FLAG{" not in evidence:
        return False, "Save the chatbot reply in artifacts/chat.txt (./scripts/chat_ai.sh)."
    return True, "LLM flag is correct and chat evidence is present."


def check_owasp(ans: dict[str, Any]) -> tuple[bool, str]:
    ai = ans.get("ai") or {}
    issue = str(ai.get("owasp_issue") or "")
    defense = str(ai.get("defense") or "")
    named = any(re.search(p, issue, re.I) for p in OWASP_PATTERNS)
    if named and nonempty(defense, 40):
        return True, "OWASP LLM issue named and a defense is described."
    return False, "Set OWASP issue to prompt injection (or LLM01) and write Defense (40+ characters)."


CheckFn = Callable[[dict[str, Any]], tuple[bool, str]]

CHECKS: list[tuple[str, str, int, CheckFn]] = [
    ("ethics", "Ethics acknowledgment", 1, check_ethics),
    ("recon_artifact", "Footprinting artifact", 1, check_recon_artifact),
    ("recon_answers", "Footprinting answers", 1, check_recon_answers),
    ("scan_artifact", "Network scan artifact", 1, check_scan_artifact),
    ("scan_answers", "Network scan answers", 1, check_scan_answers),
    ("web_flag", "Web enumeration flag", 1, check_web_flag),
    ("headers", "Missing security headers", 1, check_headers),
    ("nikto", "Web vulnerability scan artifact", 1, check_nikto),
    ("llm_flag", "AI chatbot flag", 1, check_llm_flag),
    ("owasp", "OWASP LLM issue + defense", 1, check_owasp),
]


def grade() -> dict[str, Any]:
    ans = load_answers()
    results = []
    earned = 0
    total = 0
    for key, title, points, fn in CHECKS:
        total += points
        ok, detail = fn(ans)
        if ok:
            earned += points
        results.append(
            {
                "id": key,
                "title": title,
                "points": points,
                "earned": points if ok else 0,
                "passed": ok,
                "detail": detail,
            }
        )
    return {
        "earned": earned,
        "total": total,
        "passed": earned == total,
        "results": results,
        "answers_file": "yourAnswers.md",
        "parsed": {k: v for k, v in ans.items() if not str(k).startswith("_")},
    }


def show_parsed(ans: dict[str, Any]) -> str:
    lines = [
        "What the autograder read from yourAnswers.md",
        "=" * 48,
    ]
    if ans.get("_error"):
        lines.append(f"ERROR: {ans['_error']}")
        return "\n".join(lines) + "\n"
    lines.append(f"Ethics box checked: {ans.get('ethics_acknowledged')}")
    recon = ans.get("recon") or {}
    for key in ("whois", "ns", "a", "aaaa"):
        value = recon.get(key) or "(empty)"
        preview = value.replace("\n", " / ")
        if len(preview) > 80:
            preview = preview[:77] + "..."
        lines.append(f"  {key}: {preview}")
    scan = ans.get("scan") or {}
    lines.append(f"  ports: {scan.get('ports')}")
    note = (scan.get("note") or "(empty)").replace("\n", " / ")
    lines.append(f"  note: {note[:80]}")
    web = ans.get("web") or {}
    lines.append(f"  WEB_FLAG: {web.get('web_flag') or '(empty)'}")
    lines.append(f"  missing headers: {web.get('missing_headers')}")
    ai = ans.get("ai") or {}
    lines.append(f"  LLM_FLAG: {ai.get('llm_flag') or '(empty)'}")
    lines.append(f"  OWASP issue: {ai.get('owasp_issue') or '(empty)'}")
    defense = (ai.get("defense") or "(empty)").replace("\n", " / ")
    lines.append(f"  defense: {defense[:80]}")
    lines.append("=" * 48)
    lines.append("If a field is empty, you deleted a label or wrote in the wrong place.")
    lines.append("Keep the labels (WHOIS, WEB_FLAG, Missing header 1, ...).")
    return "\n".join(lines) + "\n"


def scorecard(report: dict[str, Any]) -> str:
    lines = [
        "Lab 1 autograde",
        "=" * 48,
    ]
    err = load_answers().get("_error")
    if err:
        lines.append(f"WARNING: {err}")
    for row in report["results"]:
        mark = "PASS" if row["passed"] else "FAIL"
        lines.append(f"[{mark}] {row['earned']}/{row['points']}  {row['title']}")
        lines.append(f"       {row['detail']}")
    lines.append("=" * 48)
    lines.append(f"SCORE: {report['earned']}/{report['total']}")
    lines.append("Tip: python3 scripts/grade.py --show-parsed")
    return "\n".join(lines) + "\n"


def markdown_summary(report: dict[str, Any]) -> str:
    lines = [
        f"## Lab 1 score: {report['earned']}/{report['total']}",
        "",
        "| Result | Points | Check | Detail |",
        "|--------|--------|-------|--------|",
    ]
    for row in report["results"]:
        mark = "✅" if row["passed"] else "❌"
        detail = row["detail"].replace("|", "\\|")
        lines.append(f"| {mark} | {row['earned']}/{row['points']} | {row['title']} | {detail} |")
    lines.append("")
    lines.append("Students: fill `yourAnswers.md` and commit files under `artifacts/`.")
    return "\n".join(lines) + "\n"


def write_score_files(report: dict[str, Any]) -> None:
    ART.mkdir(exist_ok=True)
    (ART / "SCORE.txt").write_text(f"{report['earned']}/{report['total']}\n", encoding="utf-8")
    payload = {k: v for k, v in report.items() if k != "parsed"}
    (ART / "grade.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Lab 1 autograder (10 points)")
    parser.add_argument("--json", action="store_true", help="Print JSON report")
    parser.add_argument("--show-parsed", action="store_true", help="Show fields extracted from yourAnswers.md")
    parser.add_argument("--github-summary", action="store_true", help="Write GitHub Actions job summary")
    parser.add_argument("--check", metavar="ID", help="Run one check; exit 0 if it passes")
    parser.add_argument("--list-checks", action="store_true")
    args = parser.parse_args()

    if args.list_checks:
        for key, title, points, _ in CHECKS:
            print(f"{key}\t{points}\t{title}")
        return 0

    os.chdir(ROOT)

    if args.show_parsed:
        print(show_parsed(load_answers()), end="")
        return 0

    report = grade()
    write_score_files(report)

    if args.check:
        ids = {row["id"]: row for row in report["results"]}
        if args.check not in ids:
            print(f"Unknown check: {args.check}", file=sys.stderr)
            return 2
        row = ids[args.check]
        print("PASS" if row["passed"] else "FAIL")
        print(row["detail"])
        return 0 if row["passed"] else 1

    if args.json:
        print(json.dumps({k: v for k, v in report.items() if k != "parsed"}, indent=2))
    else:
        print(scorecard(report), end="")

    if args.github_summary:
        summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary_path:
            with open(summary_path, "a", encoding="utf-8") as fh:
                fh.write(markdown_summary(report))
        print(f"::notice title=Lab 1 score::{report['earned']}/{report['total']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
