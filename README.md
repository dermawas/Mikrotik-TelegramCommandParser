📡 MikroTik Telegram Command Gateway

A lightweight, reliable RouterOS automation system that lets you run MikroTik scripts remotely using Telegram commands.

Designed for:

Block/Unblock devices

Trigger automation

Run RouterOS scripts easily

Secure private Telegram group control

Survives reboots (flash/ storage)

Fully compatible with RouterOS v6

🚀 Features

✔ Run any MikroTik script using Telegram commands
✔ Stateless polling (safe for reboot, safe for daily run)
✔ Minimal JSON parsing (RouterOS-friendly)
✔ Uses flash/ so files are persistent
✔ Runs automatically via scheduler
✔ No PIN/password needed — pure !CommandName format
✔ Supports unlimited scripts:

!BlockPCMultimedia
!UnblockLaptopKid1
!BlockAll
!UnblockAll
!AnyScriptName

📁 File Structure (Recommended)
mikrotik-tg-command-gateway/
 ├─ scripts/
 │   ├─ TG_Poll.rsc
 │   ├─ TG_Step2_FetchNew.rsc
 │   ├─ TG_Step3_RunCommand.rsc
 │   ├─ BlockPCMultimedia.rsc
 │   ├─ UnblockLaptopKid1.rsc
 │   └─ ...
 ├─ README.md
 └─ LICENSE (optional)

⚙️ Architecture Overview

The system works in three layers:

Telegram → getUpdates → MikroTik → Run Script → Update State

1️⃣ TG_Step2_FetchNew

Fetches ONLY the newest Telegram update using:

getUpdates?offset=lastUpdateId+1&limit=1


Stores JSON into:

flash/tg_updates.txt

2️⃣ TG_Step3_RunCommand

Reads the JSON, extracts:

update_id

chat.id

text

Runs a script if:

Chat ID matches

Message starts with "!"

Script exists in /system script

Then updates:

flash/tg_lastupdateid.txt

3️⃣ TG_Poll (Scheduler Wrapper)

Runs Step2 + Step3 continuously.

🔧 Installation Guide
1. Create persistent files (survive reboot)

Go to MikroTik Files and create:

flash/tg_lastupdateid.txt   (content: 0)
flash/tg_updates.txt        (content: empty)


Or via terminal:

/file print file=flash/tg_lastupdateid.txt
/file set [find name="flash/tg_lastupdateid.txt"] contents="0"

 /file print file=flash/tg_updates.txt
/file set [find name="flash/tg_updates.txt"] contents=""

2. Create scripts in /system script
TG_Step2_FetchNew.rsc

(Fetch newest update)

<< paste your final working TG_Step2_FetchNew script here >>

TG_Step3_RunCommand.rsc

(Parse JSON and run MikroTik script)

<< paste your final working TG_Step3_RunCommand script here >>

TG_Poll.rsc

(Run Step2 then Step3)

/system script run TG_Step2_FetchNew
/system script run TG_Step3_RunCommand

3. Create scheduler for auto-run

Run every 10 seconds (recommended):

/system scheduler add name="TG_Poll" interval=10s on-event=TG_Poll

🎮 Usage

In your Telegram group, simply type:

!BlockPCMultimedia
!UnblockLaptopKid1
!BlockAll
!UnblockAll


The script name must match EXACTLY the script you have inside:

/system script print


Example:

Telegram command	RouterOS Script
!BlockLaptopKid1	BlockLaptopKid1
!UnblockAll	UnblockAll
!PingTest	PingTest
🧪 Example: Block Tab Kid1

Send:

!BlockTabKid1


RouterOS log:

TG_Step3: scriptName=BlockTabKid1
TG_Step3: executed BlockTabKid1
TG_Step3: state updated OK (828532939)

🔒 Security Notes

Only your specified Telegram Chat ID is allowed.

No PIN, no authentication keywords — only chat.id validation.

Use a private Telegram group.

Bot must be an admin or allowed to read messages.

🩺 Troubleshooting
❗ Step3 shows: updateId empty, abort

This is correct behavior when:

{"ok":true,"result":[]}


Means: no new command.

❗ Step3 prompts “value:”

This happens when your script does not exit early.

Your fixed version now contains:

if no update_id → return

❗ File disappears after reboot

You must use:

flash/tg_lastupdateid.txt
flash/tg_updates.txt

🗂 Versioning Suggestion

Use tags:

v1.0 – Basic polling
v1.1 – Flash storage support
v1.2 – No-PIN mode
v1.3 – Full JSON parsing fix

🌟 Credits

Created by Suseno Dermawan
Assisted by ChatGPT
System: MikroTik RouterOS v6