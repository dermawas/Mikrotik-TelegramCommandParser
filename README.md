📡 MikroTik Telegram Command Gateway

A lightweight, reliable RouterOS automation system that lets you trigger MikroTik scripts remotely using Telegram commands — without exposing your router or using unsafe webhooks.

This system is built for:

Blocking/unblocking devices

Running automation scripts

Secure remote control via a private Telegram group

Persisting state across reboots (flash storage)

Pure RouterOS scripting (no external servers)

🚀 Features
✔️ Safe & Stateless

No background server

No webhook listener

Uses Telegram getUpdates polling (safe on reboot & daily operation)

✔️ Persistent Storage

Uses flash/ directory so state survives reboot

✔️ Minimal JSON Parsing

Fully compatible with RouterOS scripting language

Efficient processing of small JSON payloads

✔️ Unlimited Commands

Works with any script you create:

!BlockPCMultimedia
!UnblockLaptopKid1
!BlockAll
!UnblockAll
!AnyScriptName

✔️ Secure

Only reacts to messages from a specific Telegram chat ID

No passwords, no PIN needed

Secure private Telegram group controls everything

✔️ Fully Compatible with RouterOS v6 & v7
📁 Recommended File Structure
mikrotik-tg-command-gateway/
│
├── scripts/
│   ├── TG_Poll.rsc
│   ├── TG_Step2_FetchNew.rsc
│   ├── TG_Step3_RunCommand.rsc
│   ├── BlockPCMultimedia.rsc
│   ├── UnblockLaptopKid1.rsc
│   ├── (your custom scripts).rsc
│
├── flash/
│   ├── tg_lastupdateid.txt
│   ├── tg_updates.txt
│
└── README.md


🧠 Architecture Overview

The system works in three layers:

Telegram → getUpdates → MikroTik → Run Script → Update State

1️⃣ TG_Step2_FetchNew

Fetches ONLY the newest Telegram update using:

getUpdates?offset=lastUpdateId+1&limit=1


Saves JSON into:

flash/tg_updates.txt

2️⃣ TG_Step3_RunCommand

Reads tg_updates.txt
Extracts:

update_id

chat_id

message text

Executes MikroTik script if:

chat_id matches your group

message begins with !

Example:

!BlockLaptopEthan


State is saved to:

flash/tg_lastupdateid.txt

3️⃣ TG_Poll (Scheduler Wrapper)

A small wrapper script that runs:

TG_Step2_FetchNew
TG_Step3_RunCommand


Used by the scheduler (e.g., every 10 seconds).

🕒 Scheduler Setup

Use:

/system scheduler add name=TG_CommandGateway interval=10s on-event=TG_Poll

🔐 Security Considerations

Always store Bot Token inside scripts securely

Only allow commands from a private Telegram group

Chat ID is hard-coded and checked in step 3

No remote API port is exposed

🧩 Example Commands

Inside Telegram:

!BlockPCMultimedia
!UnblockLaptopKid1
!BlockAll
!MyCustomScript


Inside RouterOS (script names must match):

/system script add name=BlockPCMultimedia source="..."

📦 Included Scripts
Script	Description
TG_Poll.rsc	Scheduler wrapper
TG_Step2_FetchNew.rsc	Fetch new updates
TG_Step3_RunCommand.rsc	Parse & execute commands
Custom scripts	Your automation (blocking, enabling, actions)
📝 License

MIT License (optional — add if you want)

🙌 Credits

Created by Suseno Dermawan — built live via debugging & iterative refinement.