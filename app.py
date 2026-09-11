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

# Optional separate webhook for new highest-pet notifications.
# If empty, the normal monitor webhook is used.
PET_NOTIFICATION_WEBHOOK_URL = os.environ.get(
    "PET_NOTIFICATION_WEBHOOK_URL",
    ""
)

HEARTBEAT_TIMEOUT = int(os.environ.get("HEARTBEAT_TIMEOUT", "30"))
DISCORD_UPDATE_INTERVAL = int(os.environ.get("DISCORD_UPDATE_INTERVAL", "5"))

ACCOUNTS_FILE = "accounts.json"
MESSAGE_FILE = "discord_message.json"
HIGHEST_PET_MESSAGE_FILE = "highest_pet_message.json"

accounts = {}
state_lock = threading.Lock()
discord_message_id = None
highest_pet_message_id = None


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

        pet = account.get("highestPet") or {}

        if pet:
            pet_name = str(pet.get("name") or "Unknown")
            rarity = str(pet.get("rarity") or "Unknown")
            weight = str(pet.get("weight") or "0Kg")

            try:
                cash = float(pet.get("cashPerSecond", 0))
                if cash.is_integer():
                    cash_text = f"${int(cash):,}/s"
                else:
                    cash_text = f"${cash:,.2f}/s"
            except (TypeError, ValueError):
                cash_text = "$0/s"

            pet_text = (
                f"🐾 **{pet_name}** | "
                f"✨ **{rarity}** | "
                f"💰 **{cash_text}** | "
                f"⚖️ **{weight}**"
            )
        else:
            pet_text = "🐾 **No pet detected**"

        lines.append(
            f"{icon} **{name}** — 🥚 **{eggs:,}**\n"
            f"　{pet_text}"
        )

    if not lines:
        body = "No accounts have sent a heartbeat yet."
    else:
        body = "\n".join(lines)

    if len(body) > 3900:
        body = body[:3860] + "\n…more accounts not shown"

    return body, online, offline, len(items)


# ==========================================
# SAVE AND LOAD HIGHEST PET MESSAGE ID
# ==========================================

def load_highest_pet_message():
    global highest_pet_message_id

    if not os.path.exists(HIGHEST_PET_MESSAGE_FILE):
        return

    try:
        with open(HIGHEST_PET_MESSAGE_FILE, "r", encoding="utf-8") as file:
            data = json.load(file)

        highest_pet_message_id = data.get("message_id")

        if highest_pet_message_id:
            print(
                f"📂 Loaded highest-pet Discord message ID: "
                f"{highest_pet_message_id}"
            )

    except Exception as error:
        print("❌ Could not load highest-pet Discord message ID:")
        print(repr(error))


def save_highest_pet_message():
    try:
        with open(
            HIGHEST_PET_MESSAGE_FILE,
            "w",
            encoding="utf-8"
        ) as file:
            json.dump({
                "message_id": highest_pet_message_id
            }, file)

    except Exception as error:
        print("❌ Could not save highest-pet Discord message ID:")
        print(repr(error))


# ==========================================
# HIGHEST PET NOTIFICATION
# ==========================================

def highest_pet_payload(account, pet):
    pet_name = str(pet.get("name") or "Unknown Pet")
    rarity = str(pet.get("rarity") or "Unknown")
    cash = pet.get("cashPerSecond", 0)
    weight = str(pet.get("weight") or "0Kg")
    player_name = str(
        account.get("playerName")
        or account.get("userId")
        or "Unknown"
    )

    try:
        cash_number = float(cash)
        if cash_number.is_integer():
            cash_text = f"${int(cash_number):,}/s"
        else:
            cash_text = f"${cash_number:,.2f}/s"
    except (TypeError, ValueError):
        cash_text = f"${cash}/s"

    return {
        "embeds": [{
            "title": "🔥 HIGHEST PET",
            "description": (
                f"👤 **{player_name}**\n\n"
                f"🐾 Pet: **{pet_name}**\n"
                f"✨ Rarity: **{rarity}**\n"
                f"💰 Cash/s: **{cash_text}**\n"
                f"⚖️ Weight: **{weight}**"
            ),
            "color": 16766720,
            "footer": {
                "text": "Automatically updated when a new highest pet is detected"
            },
            "timestamp": time.strftime(
                "%Y-%m-%dT%H:%M:%SZ",
                time.gmtime()
            )
        }]
    }


def update_highest_pet_notification(account, pet):
    global highest_pet_message_id

    if not pet:
        return

    webhook = (
        PET_NOTIFICATION_WEBHOOK_URL
        or DISCORD_WEBHOOK_URL
    )

    if not webhook:
        print("❌ No pet notification webhook configured")
        return

    payload = highest_pet_payload(account, pet)

    try:
        # ==========================================
        # EDIT THE EXISTING HIGHEST PET MESSAGE
        # ==========================================
        if highest_pet_message_id:
            url = (
                f"{webhook}"
                f"/messages/{highest_pet_message_id}"
            )

            response = requests.patch(
                url,
                json=payload,
                timeout=15
            )

            print(
                f"   Highest-pet PATCH status: "
                f"{response.status_code}"
            )

            if 200 <= response.status_code < 300:
                print("✅ Highest-pet message edited")
                return

            if response.status_code == 404:
                print(
                    "⚠️ Highest-pet message not found. "
                    "Creating a new one..."
                )
                highest_pet_message_id = None
                save_highest_pet_message()
            else:
                print("❌ Highest-pet PATCH error:")
                print(response.text[:1000])
                return

        # ==========================================
        # CREATE THE MESSAGE ONLY IF NONE EXISTS
        # ==========================================
        url = webhook + "?wait=true"

        response = requests.post(
            url,
            json=payload,
            timeout=15
        )

        print(
            f"   Highest-pet POST status: "
            f"{response.status_code}"
        )

        if 200 <= response.status_code < 300:
            data = response.json()
            highest_pet_message_id = data.get("id")
            save_highest_pet_message()

            print(
                "✅ Highest-pet message created | "
                f"Message ID: {highest_pet_message_id}"
            )
        else:
            print("❌ Highest-pet POST error:")
            print(response.text[:1000])

    except Exception as error:
        print("❌ Highest-pet Discord connection error:")
        print(repr(error))


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

    highest_pet = data.get("highestPet")
    if not isinstance(highest_pet, dict):
        highest_pet = None

    with state_lock:
        previous_account = accounts.get(user_id, {})
        previous_pet = previous_account.get("highestPet") or {}

        accounts[user_id] = {
            "userId": user_id,
            "playerName": player_name,
            "displayName": display_name,
            "eggs": eggs,
            "highestPet": highest_pet,
            "lastSeen": time.time()
        }

    print(
        f"📡 Heartbeat received: "
        f"{player_name} | 🥚 Eggs: {eggs}"
    )

    if highest_pet:
        print(
            f"   🐾 Highest pet: "
            f"{highest_pet.get('name', 'Unknown')} | "
            f"{highest_pet.get('rarity', 'Unknown')} | "
            f"${highest_pet.get('cashPerSecond', 0)}/s | "
            f"{highest_pet.get('weight', '0Kg')}"
        )

    previous_uid = str(previous_pet.get("uid", ""))
    current_uid = str(highest_pet.get("uid", "")) if highest_pet else ""

    if current_uid and current_uid != previous_uid:
        threading.Thread(
            target=update_highest_pet_notification,
            args=(
                {
                    "userId": user_id,
                    "playerName": player_name,
                    "displayName": display_name
                },
                highest_pet
            ),
            daemon=True
        ).start()


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
load_highest_pet_message()


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
