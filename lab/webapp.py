#!/usr/bin/env python3
"""Intentionally insecure lab web app on port 3000 (CEH modules 4, 5, 13, 14)."""
from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from flags import WEB_FLAG  # noqa: E402

HOST = "0.0.0.0"
PORT = 3000

HOME = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Campus Portal — Lab Target</title>
</head>
<body>
  <h1>Campus Portal</h1>
  <p>Welcome to the Network Applications lab target (port 3000).</p>
  <p>This application is <strong>intentionally misconfigured</strong> for class use.</p>
  <ul>
    <li><a href="/robots.txt">robots.txt</a></li>
    <li><a href="/admin">Admin</a></li>
    <li><a href="/files/">Files</a></li>
  </ul>
  <p>Status: ok</p>
</body>
</html>
"""

ROBOTS = """User-agent: *
Disallow: /hidden/
Disallow: /admin
Disallow: /files/
# Please do not index internal backup notes.
"""

NOTES = f"""INTERNAL BACKUP NOTES — do not publish
Owner: lab-admin
Ticket: NAS-3000
{WEB_FLAG}
"""

ADMIN = """<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Admin</title></head>
<body>
  <h1>403 Forbidden</h1>
  <p>Admin console is not available to anonymous users.</p>
  <p>Server: InsecureLab/0.1 / Python http.server</p>
</body>
</html>
"""

FILES = """<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Index of /files/</title></head>
<body>
  <h1>Index of /files/</h1>
  <ul>
    <li><a href="/files/readme.txt">readme.txt</a></li>
    <li><a href="/hidden/notes.txt">../hidden/notes.txt</a></li>
  </ul>
</body>
</html>
"""

README_FILE = "Lab file share. Nothing sensitive here.\n"


class LabHandler(BaseHTTPRequestHandler):
    server_version = "InsecureLab/0.1"
    sys_version = ""

    def _send(self, code: int, body: str | bytes, content_type: str = "text/html; charset=utf-8") -> None:
        data = body.encode("utf-8") if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        # Intentionally missing: X-Frame-Options, CSP, HSTS, X-Content-Type-Options
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def do_HEAD(self) -> None:
        self.do_GET()

    def do_GET(self) -> None:
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            self._send(200, HOME)
        elif path == "/robots.txt":
            self._send(200, ROBOTS, "text/plain; charset=utf-8")
        elif path == "/hidden/notes.txt":
            self._send(200, NOTES, "text/plain; charset=utf-8")
        elif path == "/admin":
            self._send(403, ADMIN)
        elif path in ("/files", "/files/"):
            self._send(200, FILES)
        elif path == "/files/readme.txt":
            self._send(200, README_FILE, "text/plain; charset=utf-8")
        elif path == "/.git/HEAD":
            self._send(200, "ref: refs/heads/main\n", "text/plain; charset=utf-8")
        elif path == "/health":
            self._send(200, json.dumps({"ok": True, "port": PORT}), "application/json")
        else:
            self._send(404, "Not found\n", "text/plain; charset=utf-8")

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


def main() -> None:
    httpd = ThreadingHTTPServer((HOST, PORT), LabHandler)
    print(f"[webapp] listening on http://127.0.0.1:{PORT}", flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
