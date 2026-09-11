import os
import time
import json
import threading

from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# ==========================================
# SETTINGS
# ==========================================

API_KEY = os.environ.get(
    "API_KEY",
    "CHANGE_THIS_SECRET_KEY"
)

# DO NOT CHANGE YOUR WEBHOOK
DISCORD_WEBHOOK_URL = os.environ.get(
    "DISCORD_WEBHOOK_URL",
    ""
)

HEARTBEAT_TIMEOUT = int(
    os.environ.get("HEARTBEAT_TIMEOUT", "30")
)

DISCORD_UPDATE_INTERVAL = int(
    os.environ.get("DISCORD_UPDATE_INTERVAL", "5")
)

ACCOUNTS_FILE = "accounts.json"
MESSAGE_FILE = "discord_message.json"


# ==========================================
# DATA
# ==========================================

accounts = {}

state_lock = threading.Lock()

discord_message_id = None


# ==========================================
# NUMBER FORMAT
# ==========================================

def format_money(value):

    try:
        value = float(value)
    except (TypeError, ValueError):
        return "0"

    if value >= 1_000_000_000_000:
        return f"{value / 1_000_000_000_000:.2f}T"

    if value >= 1_000_000_000:
        return f"{value / 1_000_000_000:.2f}B"

    if value >= 1_000_000:
        return f"{value / 1_000_000:.2f}M"

    if value >= 1_000:
        return f"{value / 1_000:.2f}K"

    return f"{value:,.0f}"


# ==========================================
# LOAD ACCOUNTS
# ==========================================

def load_accounts():

    global accounts

    if not os.path.exists(ACCOUNTS_FILE):
        print("📁 No previous accounts file found")
        return

    try:

        with open(
            ACCOUNTS_FILE,
            "r",
            encoding="utf-8"
        ) as file:

            data = json.load(file)

        if isinstance(data, dict):

            accounts = data

            print(
                f"📂 Loaded {len(accounts)} "
                f"saved account(s)"
            )

    except Exception as error:

        print("❌ Could not load accounts:")
        print(repr(error))


# ==========================================
# SAVE ACCOUNTS
# ==========================================

def save_accounts():

    try:

        with state_lock:

            data = accounts.copy()

        with open(
            ACCOUNTS_FILE,
            "w",
            encoding="utf-8"
        ) as file:

            json.dump(
                data,
                file,
                indent=2
            )

    except Exception as error:

        print("❌ Could not save accounts:")
        print(repr(error))


# ==========================================
# LOAD DISCORD MESSAGE
# ==========================================

def load_discord_message():

    global discord_message_id

    if not os.path.exists(MESSAGE_FILE):
        return

    try:

        with open(
            MESSAGE_FILE,
            "r",
            encoding="utf-8"
        ) as file:

            data = json.load(file)

        discord_message_id = data.get(
            "message_id"
        )

        if discord_message_id:

            print(
                "📂 Loaded Discord message ID: "
                f"{discord_message_id}"
            )

    except Exception as error:

        print(
            "❌ Could not load Discord message ID:"
        )

        print(repr(error))


# ==========================================
# SAVE DISCORD MESSAGE
# ==========================================

def save_discord_message():

    try:

        with open(
            MESSAGE_FILE,
            "w",
            encoding="utf-8"
        ) as file:

            json.dump(
                {
                    "message_id":
                        discord_message_id
                },
                file
            )

    except Exception as error:

        print(
            "❌ Could not save Discord "
            "message ID:"
        )

        print(repr(error))


# ==========================================
# API KEY
# ==========================================

def check_key(req):

    return (
        req.headers.get("X-API-Key")
        == API_KEY
    )


# ==========================================
# ACCOUNT DISPLAY
# ==========================================

def dashboard_text():

    now = time.time()

    with state_lock:

        items = list(
            accounts.values()
        )

    lines = []

    online = 0
    offline = 0


    # ======================================
    # SORT ACCOUNTS
    # ======================================

    items.sort(
        key=lambda x: (
            x.get("playerName") or ""
        ).lower()
    )


    # ======================================
    # EACH ACCOUNT
    # ======================================

    for account in items:

        last_seen = float(
            account.get(
                "lastSeen",
                0
            )
        )

        is_online = (
            now - last_seen
        ) <= HEARTBEAT_TIMEOUT


        if is_online:

            online += 1

            icon = "🟢 ONLINE"

        else:

            offline += 1

            icon = "🔴 OFFLINE"


        name = (
            account.get("playerName")
            or account.get("userId")
            or "Unknown"
        )


        # ==================================
        # ACCOUNT NAME
        # ==================================

        lines.append(
            f"{icon} **{name}**"
        )


        # ==================================
        # DISPLAY NAME
        # ==================================

        display_name = account.get(
            "displayName",
            ""
        )

        if display_name:

            lines.append(
                f"👤 Display: **{display_name}**"
            )


        # ==================================
        # CASH
        # ==================================

        cash = account.get(
            "cash",
            None
        )

        if cash is None:

            lines.append(
                "💵 Cash: **Not received**"
            )

        else:

            lines.append(
                f"💵 Cash: **${format_money(cash)}**"
            )


        # ==================================
        # EGG INVENTORY
        # ==================================

        egg_inventory = account.get(
            "eggInventory",
            {}
        )

        if (
            isinstance(
                egg_inventory,
                dict
            )
            and len(egg_inventory) > 0
        ):

            lines.append(
                "🥚 **EGG INVENTORY**"
            )

            for egg_name, amount in sorted(
                egg_inventory.items(),
                key=lambda x: str(x[0]).lower()
            ):

                try:
                    amount = int(amount)
                except (TypeError, ValueError):
                    amount = 0

                lines.append(
                    f"• {egg_name} × **{amount}**"
                )

        else:

            total_eggs = account.get(
                "eggs",
                0
            )

            try:
                total_eggs = int(
                    total_eggs
                )
            except (TypeError, ValueError):
                total_eggs = 0

            if total_eggs > 0:

                lines.append(
                    f"🥚 Eggs: **{total_eggs}**"
                )

            else:

                lines.append(
                    "🥚 Egg Inventory: **Not received**"
                )


        # ==================================
        # HIGHEST WEIGHT PET
        # ==================================

        weight_pet = account.get(
            "highestWeightPet"
        )

        if (
            isinstance(
                weight_pet,
                dict
            )
            and weight_pet
        ):

            pet_name = weight_pet.get(
                "name",
                "Unknown"
            )

            weight = weight_pet.get(
                "weight",
                0
            )

            mutation = weight_pet.get(
                "mutation",
                "None"
            )

            try:
                weight = float(weight)
            except (TypeError, ValueError):
                weight = 0


            lines.append(
                "🏆 **HIGHEST WEIGHT PET**"
            )

            lines.append(
                f"🐾 Pet: **{pet_name}**"
            )

            lines.append(
                f"⚖️ Weight: **{weight:,.2f} KG**"
            )

            lines.append(
                f"🧬 Mutation: **{mutation}**"
            )

        else:

            lines.append(
                "🏆 Highest Weight Pet: "
                "**Not received**"
            )


        # ==================================
        # HIGHEST MONEY/S PET
        # ==================================

        money_pet = account.get(
            "highestMoneyPet"
        )

        if (
            isinstance(
                money_pet,
                dict
            )
            and money_pet
        ):

            pet_name = money_pet.get(
                "name",
                "Unknown"
            )

            money_per_second = (
                money_pet.get(
                    "moneyPerSecond",
                    0
                )
            )

            mutation = money_pet.get(
                "mutation",
                "None"
            )

            try:

                money_per_second = float(
                    money_per_second
                )

            except (
                TypeError,
                ValueError
            ):

                money_per_second = 0


            lines.append(
                "💰 **HIGHEST MONEY/s PET**"
            )

            lines.append(
                f"🐾 Pet: **{pet_name}**"
            )

            lines.append(
                f"💵 Money/s: "
                f"**${format_money(money_per_second)}/s**"
            )

            lines.append(
                f"🧬 Mutation: **{mutation}**"
            )

        else:

            lines.append(
                "💰 Highest Money/s Pet: "
                "**Not received**"
            )


        # ==================================
        # SEPARATOR
        # ==================================

        lines.append("")
        lines.append("━━━━━━━━━━━━━━━━━━")
        lines.append("")


    # ======================================
    # NO ACCOUNTS
    # ======================================

    if not lines:

        body = (
            "No accounts have sent "
            "a heartbeat yet."
        )

    else:

        body = "\n".join(lines)


    # ======================================
    # DISCORD LIMIT
    # ======================================

    if len(body) > 3900:

        body = (
            body[:3860]
            + "\n…more accounts not shown"
        )


    return (
        body,
        online,
        offline,
        len(items)
    )


# ==========================================
# DISCORD PAYLOAD
# ==========================================

def discord_payload():

    body, online, offline, total = (
        dashboard_text()
    )

    return {

        "embeds": [

            {

                "title":
                    "🥚 KYOSH ACCOUNT MONITOR",

                "description":
                    body,

                "color":
                    5763719
                    if offline == 0
                    else 15158332,

                "footer":
                    {
                        "text":
                            (
                                f"Online: {online} | "
                                f"Offline: {offline} | "
                                f"Total: {total}"
                            )
                    },

                "timestamp":
                    time.strftime(
                        "%Y-%m-%dT%H:%M:%SZ",
                        time.gmtime()
                    )
            }

        ]

    }


# ==========================================
# UPDATE DISCORD
# ==========================================

def update_discord():

    global discord_message_id

    if not DISCORD_WEBHOOK_URL:

        print(
            "❌ DISCORD_WEBHOOK_URL is empty"
        )

        return


    payload = discord_payload()


    with state_lock:

        account_count = len(
            accounts
        )


    print(
        "💬 Updating Discord..."
    )

    print(
        f"   Accounts: {account_count}"
    )

    print(
        "   Existing message ID: "
        f"{discord_message_id}"
    )


    try:

        # ==================================
        # EDIT EXISTING MESSAGE
        # ==================================

        if discord_message_id:

            url = (
                f"{DISCORD_WEBHOOK_URL}"
                f"/messages/"
                f"{discord_message_id}"
            )


            response = requests.patch(
                url,
                json=payload,
                timeout=15
            )


            print(
                "   Discord PATCH status: "
                f"{response.status_code}"
            )


            if (
                200
                <= response.status_code
                < 300
            ):

                print(
                    "✅ Discord message updated"
                )

                return


            if response.status_code == 404:

                print(
                    "⚠️ Discord message not "
                    "found. Creating a new one..."
                )

                discord_message_id = None

                save_discord_message()


            else:

                print(
                    "❌ Discord PATCH error:"
                )

                print(
                    response.text[:1000]
                )

                return


        # ==================================
        # CREATE MESSAGE
        # ==================================

        url = (
            DISCORD_WEBHOOK_URL
            + "?wait=true"
        )


        response = requests.post(
            url,
            json=payload,
            timeout=15
        )


        print(
            "   Discord POST status: "
            f"{response.status_code}"
        )


        if (
            200
            <= response.status_code
            < 300
        ):

            data = response.json()

            discord_message_id = data.get(
                "id"
            )

            save_discord_message()


            print(
                "✅ Discord monitor "
                "message created"
            )

            print(
                "   Message ID: "
                f"{discord_message_id}"
            )

        else:

            print(
                "❌ Discord POST error:"
            )

            print(
                response.text[:1000]
            )


    except Exception as error:

        print(
            "❌ Discord connection error:"
        )

        print(repr(error))


# ==========================================
# MONITOR LOOP
# ==========================================

def monitor_loop():

    print(
        "🚀 Discord monitor loop started"
    )


    while True:

        try:

            update_discord()

        except Exception as error:

            print(
                "❌ Monitor loop error:",
                repr(error)
            )


        time.sleep(
            DISCORD_UPDATE_INTERVAL
        )


# ==========================================
# WEBSITE
# ==========================================

@app.get("/")
def home():

    body, online, offline, total = (
        dashboard_text()
    )


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
    font-size: 17px;
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
# HEALTH
# ==========================================

@app.get("/health")
def health():

    body, online, offline, total = (
        dashboard_text()
    )


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

    # ======================================
    # API KEY
    # ======================================

    if not check_key(request):

        print(
            "❌ Unauthorized heartbeat request"
        )

        return jsonify({

            "ok": False,

            "error": "Unauthorized"

        }), 401


    # ======================================
    # READ JSON
    # ======================================

    data = request.get_json(
        silent=True
    ) or {}


    # ======================================
    # USER ID
    # ======================================

    user_id = str(
        data.get(
            "userId",
            ""
        )
    ).strip()


    if not user_id:

        print(
            "❌ Heartbeat missing userId"
        )

        return jsonify({

            "ok": False,

            "error": "Missing userId"

        }), 400


    # ======================================
    # BASIC ACCOUNT DATA
    # ======================================

    player_name = str(
        data.get(
            "playerName"
        )
        or user_id
    )


    display_name = str(
        data.get(
            "displayName"
        )
        or ""
    )


    # ======================================
    # TOTAL EGGS
    # ======================================

    try:

        eggs = int(
            data.get(
                "eggs",
                0
            )
        )

    except (
        TypeError,
        ValueError
    ):

        eggs = 0


    # ======================================
    # CASH
    # ======================================

    cash = data.get(
        "cash",
        None
    )


    if cash is not None:

        try:

            cash = float(cash)

        except (
            TypeError,
            ValueError
        ):

            cash = 0


    # ======================================
    # EGG INVENTORY
    # ======================================

    egg_inventory = data.get(
        "eggInventory",
        {}
    )


    if not isinstance(
        egg_inventory,
        dict
    ):

        egg_inventory = {}


    # ======================================
    # HIGHEST WEIGHT PET
    # ======================================

    highest_weight_pet = data.get(
        "highestWeightPet"
    )


    if not isinstance(
        highest_weight_pet,
        dict
    ):

        highest_weight_pet = None


    # ======================================
    # HIGHEST MONEY/S PET
    # ======================================

    highest_money_pet = data.get(
        "highestMoneyPet"
    )


    if not isinstance(
        highest_money_pet,
        dict
    ):

        highest_money_pet = None


    # ======================================
    # STORE ACCOUNT
    # ======================================

    with state_lock:

        accounts[user_id] = {

            "userId":
                user_id,

            "playerName":
                player_name,

            "displayName":
                display_name,

            "eggs":
                eggs,

            "eggInventory":
                egg_inventory,

            "cash":
                cash,

            "highestWeightPet":
                highest_weight_pet,

            "highestMoneyPet":
                highest_money_pet,

            "lastSeen":
                time.time()
        }


    # ======================================
    # LOG
    # ======================================

    print(
        f"📡 Heartbeat received: "
        f"{player_name} | "
        f"💵 Cash: {cash} | "
        f"🥚 Eggs: {eggs}"
    )


    if highest_weight_pet:

        print(
            "🏆 Highest weight pet: "
            f"{highest_weight_pet.get('name')} | "
            f"{highest_weight_pet.get('weight')} KG"
        )


    if highest_money_pet:

        print(
            "💰 Highest Money/s pet: "
            f"{highest_money_pet.get('name')} | "
            f"{highest_money_pet.get('moneyPerSecond')}/s"
        )


    # ======================================
    # SAVE
    # ======================================

    save_accounts()


    # ======================================
    # UPDATE DISCORD
    # ======================================

    threading.Thread(
        target=update_discord,
        daemon=True
    ).start()


    return jsonify({

        "ok": True,

        "message":
            "Heartbeat received",

        "account":
            player_name

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
# RUN
# ==========================================

if __name__ == "__main__":

    port = int(
        os.environ.get(
            "PORT",
            "10000"
        )
    )


    app.run(
        host="0.0.0.0",
        port=port
    )
