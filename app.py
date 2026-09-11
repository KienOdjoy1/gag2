import os
import time
import json
import threading
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

API_KEY = os.environ.get("API_KEY", "CHANGE_THIS_SECRET_KEY")

# KEEP YOUR WEBHOOK ENVIRONMENT VARIABLE THE SAME
DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL", "")

HEARTBEAT_TIMEOUT = int(os.environ.get("HEARTBEAT_TIMEOUT", "30"))
DISCORD_UPDATE_INTERVAL = int(os.environ.get("DISCORD_UPDATE_INTERVAL", "5"))

ACCOUNTS_FILE = "accounts.json"
MESSAGE_FILE = "discord_message.json"

accounts = {}
state_lock = threading.Lock()
discord_message_id = None


# ==========================================
# SAVE AND LOAD ACCOUNTS
# ==========================================

def load_accounts():
    global accounts

    if not os.path.exists(ACCOUNTS_FILE):
        print("📁 No previous accounts file found")
        return

    try:
        with open(ACCOUNTS_FILE, "r", encoding="utf-8") as file:
            data = json.load(file)

        if isinstance(data, dict):
            accounts = data
            print(f"📂 Loaded {len(accounts)} saved account(s)")

    except Exception as error:
        print("❌ Could not load accounts:")
        print(repr(error))


def save_accounts():
    try:
        with state_lock:
            data = accounts.copy()

        with open(ACCOUNTS_FILE, "w", encoding="utf-8") as file:
            json.dump(data, file, indent=2)

    except Exception as error:
        print("❌ Could not save accounts:")
        print(repr(error))


# ==========================================
# SAVE AND LOAD DISCORD MESSAGE ID
# ==========================================

def load_discord_message():
    global discord_message_id

    if not os.path.exists(MESSAGE_FILE):
        return

    try:
        with open(MESSAGE_FILE, "r", encoding="utf-8") as file:
            data = json.load(file)

        discord_message_id = data.get("message_id")

        if discord_message_id:
            print(f"📂 Loaded Discord message ID: {discord_message_id}")

    except Exception as error:
        print("❌ Could not load Discord message ID:")
        print(repr(error))


def save_discord_message():
    try:
        with open(MESSAGE_FILE, "w", encoding="utf-8") as file:
            json.dump({
                "message_id": discord_message_id
            }, file)

    except Exception as error:
        print("❌ Could not save Discord message ID:")
        print(repr(error))


# ==========================================
# API KEY CHECK
# ==========================================

def check_key(req):
    return req.headers.get("X-API-Key") == API_KEY


# ==========================================
# DASHBOARD
# ==========================================

def dashboard_text():
    now = time.time()

    with state_lock:
        items = list(accounts.values())

    lines = []
    online = 0
    offline = 0

    for account in sorted(
        items,
        key=lambda x: (x.get("playerName") or "").lower()
    ):
        last_seen = float(account.get("lastSeen", 0))

        is_online = (
            now - last_seen
        ) <= HEARTBEAT_TIMEOUT

        if is_online:
            online += 1
            icon = "🟢 ONLINE"
        else:
            offline += 1
            icon = "🔴 OFFLINE"

        name = account.get("playerName") or account.get("userId")
        eggs = int(account.get("eggs", 0))

        lines.append(
            f"{icon} **{name}** — 🥚 **{eggs:,}**"
        )

    if not lines:
        body = "No accounts have sent a heartbeat yet."
    else:
        body = "\n".join(lines)

    if len(body) > 3900:
        body = body[:3860] + "\n…more accounts not shown"

    return body, online, offline, len(items)


# ==========================================
# DISCORD PAYLOAD
# ==========================================

def discord_payload():
    body, online, offline, total = dashboard_text()

    return {
        "embeds": [{
            "title": "🥚 KYOSH ACCOUNT MONITOR",
            "description": body,
            "color": 5763719 if offline == 0 else 15158332,
            "footer": {
                "text": (
                    f"Online: {online} | "
                    f"Offline: {offline} | "
                    f"Total: {total}"
                )
            },
            "timestamp": time.strftime(
                "%Y-%m-%dT%H:%M:%SZ",
                time.gmtime()
            )
        }]
    }


# ==========================================
# UPDATE DISCORD
# ==========================================

def update_discord():
    global discord_message_id

    if not DISCORD_WEBHOOK_URL:
        print("❌ DISCORD_WEBHOOK_URL is empty")
        return

    payload = discord_payload()

    with state_lock:
        account_count = len(accounts)

    print("💬 Updating Discord...")
    print(f"   Accounts: {account_count}")
    print(f"   Existing message ID: {discord_message_id}")

    try:

        # Edit existing monitor message
        if discord_message_id:

            url = (
                f"{DISCORD_WEBHOOK_URL}"
                f"/messages/{discord_message_id}"
            )

            response = requests.patch(
                url,
                json=payload,
                timeout=15
            )

            print(
                f"   Discord PATCH status: "
                f"{response.status_code}"
            )

            if 200 <= response.status_code < 300:
                print("✅ Discord message updated")
                return

            if response.status_code == 404:
                print(
                    "⚠️ Discord message not found. "
                    "Creating a new one..."
                )

                discord_message_id = None
                save_discord_message()

            else:
                print("❌ Discord PATCH error:")
                print(response.text[:1000])
                return


        # Create monitor message
        url = DISCORD_WEBHOOK_URL + "?wait=true"

        response = requests.post(
            url,
            json=payload,
            timeout=15
        )

        print(
            f"   Discord POST status: "
            f"{response.status_code}"
        )

        if 200 <= response.status_code < 300:

            data = response.json()

            discord_message_id = data.get("id")

            save_discord_message()

            print("✅ Discord monitor message created")
            print(
                f"   Message ID: "
                f"{discord_message_id}"
            )

        else:
            print("❌ Discord POST error:")
            print(response.text[:1000])

    except Exception as error:
        print("❌ Discord connection error:")
        print(repr(error))


# ==========================================
# DISCORD MONITOR LOOP
# ==========================================

def monitor_loop():

    print("🚀 Discord monitor loop started")

    while True:

        try:
            update_discord()

        except Exception as error:
            print(
                "❌ Monitor loop error:",
                repr(error)
            )

        time.sleep(DISCORD_UPDATE_INTERVAL)


# ==========================================
# WEBSITE
# ==========================================

@app.get("/")
def home():

    body, online, offline, total = dashboard_text()

    return f"""<!doctype html>
<html>
<head>

<meta charset="utf-8">

<meta
    name="viewport"
    content="width=device-width,initial-scale=1"
>

<title>Kyosh Account Monitor</title>

<style>

body {{
    font-family: Arial, sans-serif;
    background: #111;
    color: #eee;
    max-width: 900px;
    margin: 40px auto;
    padding: 20px;
}}

.card {{
    background: #1d1d1d;
    border-radius: 14px;
    padding: 20px;
}}

pre {{
    white-space: pre-wrap;
    font-size: 18px;
    line-height: 1.7;
}}

.small {{
    color: #aaa;
}}

</style>

</head>

<body>

<div class="card">

<h1>🥚 KYOSH ACCOUNT MONITOR</h1>

<p class="small">
Online: {online} |
Offline: {offline} |
Total: {total}
</p>

<pre>{body}</pre>

</div>

</body>
</html>"""


# ==========================================
# HEALTH CHECK
# ==========================================

@app.get("/health")
def health():

    body, online, offline, total = dashboard_text()

    return jsonify({
        "ok": True,
        "online": online,
        "offline": offline,
        "accounts": total,
        "discord_message_id_exists":
            discord_message_id is not None
    })


# ==========================================
# HEARTBEAT
# ==========================================

@app.post("/heartbeat")
def heartbeat():

    if not check_key(request):
        print("❌ Unauthorized heartbeat request")

        return jsonify({
            "ok": False,
            "error": "Unauthorized"
        }), 401


    data = request.get_json(silent=True) or {}

    user_id = str(
        data.get("userId", "")
    ).strip()


    if not user_id:

        print("❌ Heartbeat missing userId")

        return jsonify({
            "ok": False,
            "error": "Missing userId"
        }), 400


    player_name = str(
        data.get("playerName") or user_id
    )

    display_name = str(
        data.get("displayName") or ""
    )

    try:
        eggs = int(data.get("eggs", 0))

    except (TypeError, ValueError):
        eggs = 0


    with state_lock:

        accounts[user_id] = {
            "userId": user_id,
            "playerName": player_name,
            "displayName": display_name,
            "eggs": eggs,
            "lastSeen": time.time()
        }


    print(
        f"📡 Heartbeat received: "
        f"{player_name} | 🥚 Eggs: {eggs}"
    )


    # Save the account permanently
    save_accounts()


    # Update Discord immediately
    threading.Thread(
        target=update_discord,
        daemon=True
    ).start()


    return jsonify({
        "ok": True,
        "message": "Heartbeat received"
    })


# ==========================================
# STARTUP
# ==========================================

load_accounts()
load_discord_message()


threading.Thread(
    target=monitor_loop,
    daemon=True
).start()


# ==========================================
# RUN SERVER
# ==========================================

if __name__ == "__main__":

    port = int(
        os.environ.get("PORT", "10000")
    )

    app.run(
        host="0.0.0.0",
        port=port
    )
