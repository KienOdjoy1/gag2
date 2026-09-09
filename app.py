import os
import json
import time
import threading
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

API_KEY = os.environ.get("API_KEY", "CHANGE_THIS_SECRET_KEY")
DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL", "")
HEARTBEAT_TIMEOUT = int(os.environ.get("HEARTBEAT_TIMEOUT", "30"))
DISCORD_UPDATE_INTERVAL = int(os.environ.get("DISCORD_UPDATE_INTERVAL", "5"))

accounts = {}
state_lock = threading.Lock()
discord_message_id = None

def check_key(req):
    return req.headers.get("X-API-Key") == API_KEY

def dashboard_text():
    now = time.time()
    with state_lock:
        items = list(accounts.values())

    lines = []
    online = 0
    offline = 0

    for a in sorted(items, key=lambda x: (x.get("playerName") or "").lower()):
        is_online = (now - a.get("lastSeen", 0)) <= HEARTBEAT_TIMEOUT
        if is_online:
            online += 1
            icon = "🟢 ONLINE"
        else:
            offline += 1
            icon = "🔴 OFFLINE"

        name = a.get("playerName") or str(a.get("userId"))
        eggs = a.get("eggs", 0)
        lines.append(f"{icon} **{name}** — 🥚 **{eggs:,}**")

    if not lines:
        body = "No accounts have sent a heartbeat yet."
    else:
        body = "\n".join(lines)

    # Discord embed description limit is 4096 characters.
    if len(body) > 3900:
        body = body[:3860] + "\n…more accounts not shown"

    return body, online, offline, len(items)

def discord_payload():
    body, online, offline, total = dashboard_text()
    return {
        "embeds": [{
            "title": "🥚 KYOSH ACCOUNT MONITOR",
            "description": body,
            "color": 5763719 if offline == 0 else 15158332,
            "footer": {
                "text": f"Online: {online} | Offline: {offline} | Total: {total}"
            },
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        }]
    }

def update_discord():
    global discord_message_id

    if not DISCORD_WEBHOOK_URL:
        return

    payload = discord_payload()

    try:
        if discord_message_id:
            url = f"{DISCORD_WEBHOOK_URL}/messages/{discord_message_id}"
            r = requests.patch(url, json=payload, timeout=15)
            if r.status_code == 404:
                discord_message_id = None
            elif not (200 <= r.status_code < 300):
                print("Discord PATCH error:", r.status_code, r.text[:300])
                return

        if not discord_message_id:
            url = DISCORD_WEBHOOK_URL + "?wait=true"
            r = requests.post(url, json=payload, timeout=15)
            if 200 <= r.status_code < 300:
                data = r.json()
                discord_message_id = data.get("id")
                print("Created Discord monitor message:", discord_message_id)
            else:
                print("Discord POST error:", r.status_code, r.text[:300])
    except Exception as e:
        print("Discord update error:", e)

def monitor_loop():
    while True:
        try:
            update_discord()
        except Exception as e:
            print("Monitor loop error:", e)
        time.sleep(DISCORD_UPDATE_INTERVAL)

@app.get("/")
def home():
    body, online, offline, total = dashboard_text()
    return f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Kyosh Account Monitor</title>
<style>
body{{font-family:Arial,sans-serif;background:#111;color:#eee;max-width:900px;margin:40px auto;padding:20px}}
.card{{background:#1d1d1d;border-radius:14px;padding:20px}}
pre{{white-space:pre-wrap;font-size:18px;line-height:1.7}}
.small{{color:#aaa}}
</style>
</head>
<body>
<div class="card">
<h1>🥚 KYOSH ACCOUNT MONITOR</h1>
<p class="small">Online: {online} | Offline: {offline} | Total: {total}</p>
<pre>{body}</pre>
</div>
</body>
</html>"""

@app.get("/health")
def health():
    return jsonify({"ok": True, "accounts": len(accounts)})

@app.post("/heartbeat")
def heartbeat():
    if not check_key(request):
        return jsonify({"ok": False, "error": "Unauthorized"}), 401

    data = request.get_json(silent=True) or {}
    user_id = str(data.get("userId", "")).strip()
    if not user_id:
        return jsonify({"ok": False, "error": "Missing userId"}), 400

    with state_lock:
        old = accounts.get(user_id, {})
        accounts[user_id] = {
            "userId": user_id,
            "playerName": str(data.get("playerName") or old.get("playerName") or user_id),
            "displayName": str(data.get("displayName") or old.get("displayName") or ""),
            "eggs": int(data.get("eggs", old.get("eggs", 0))),
            "lastSeen": time.time()
        }

    return jsonify({"ok": True})

threading.Thread(target=monitor_loop, daemon=True).start()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "10000"))
    app.run(host="0.0.0.0", port=port)
