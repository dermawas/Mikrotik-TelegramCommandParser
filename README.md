📡 MikroTik Telegram Command Gateway

A lightweight, reliable RouterOS automation system that lets you run MikroTik scripts remotely using Telegram commands.

Designed for:

Blocking/unblocking devices

Triggering automation

Running RouterOS scripts easily

Secure private Telegram-controlled operations

Survives reboots using flash/ storage

Compatible with RouterOS v6 (tested on 6.49.x)

🚀 Features

✔ Run any MikroTik script using Telegram commands

✔ Stateless polling (safe for reboot, safe for scheduler)

✔ Minimal JSON parsing (RouterOS-friendly)

✔ Uses flash/ so files survive reboot

✔ Works automatically via scheduler

✔ No PIN/password needed — Telegram group controls access

✔ Supports unlimited commands:

!BlockPCMultimedia
!UnblockLaptopKid1
!BlockAll
!UnblockAll
!AnyScriptName

📁 Recommended Repository Structure

mikrotik-tg-command-gateway/

├── scripts/

│   ├── TG_Step1_StateFile.rsc (Run this once to create the 2 files needed in flash folder)

│   ├── TG_Poll.rsc

│   ├── TG_Step2_FetchNew.rsc

│   └── TG_Step3_RunCommand.rsc

│   ├── BlockPCMultimedia.rsc

│   ├── UnblockPCMUltimedia.rsc

│   ├── TGBotSenderScript.rsc

│

│── flash/

│   ├── tg_lastupdateid.txt

│   └── tg_updates.txt

│

└── README.md


🧠 Architecture Overview

The system works in three layers:

Telegram → getUpdates → MikroTik → Run Script → Update State

🔍 Step 2 — TG_Step2_FetchNew

Fetch only the newest Telegram update, using:

getUpdates?offset=lastUpdateId+1&limit=1


Stores a small JSON into:

flash/tg_updates.txt

Example:

{"ok":true,"result":[]}

⚙ Step 3 — TG_Step3_RunCommand

Reads update_id

Validates correct chat

Detects text starting with !

Strips the !

Runs the MikroTik script with the same name

Updates:

flash/tg_lastupdateid.txt

🕒 Scheduler Wrapper

Runs both Step2 & Step3 every 10 seconds:

/system scheduler add name="TG_Poll" interval=10s on-event=TG_Poll.rsc

🔐 Security

Only reacts to messages from your Telegram group

No passwords

No PIN

RouterOS scripts remain internal and private

📦 File Requirements

These must exist in flash/:

flash/tg_lastupdateid.txt   (contains a number)
flash/tg_updates.txt        (auto updated)
