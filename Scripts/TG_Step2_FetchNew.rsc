# TG_Step2_FetchNew  (flash / persistent version)
# Goal: use lastUpdateId from flash/tg_lastupdateid.txt,
#       fetch ONLY newer updates, and store them in flash/tg_updates.txt

:local BotToken "<BotToken>"
:local stateFile "flash/tg_lastupdateid.txt"
:local updatesFile "flash/tg_updates.txt"

# --- read lastUpdateId from file ---
:local lastUpdateId 0
:local fId [/file find name=$stateFile]

:if ([:len $fId] = 0) do={
    :put "TG_Step2: state file missing, run TG_Step1_StateFile first"
    :return
}

:local rawLast [/file get $fId contents]
:if ([:len $rawLast] > 0) do={
    :set lastUpdateId [:tonum $rawLast]
}

:put ("TG_Step2: lastUpdateId=" . $lastUpdateId)

# --- fetch new update from Telegram (offset = last+1, limit=1) ---
:local offset ($lastUpdateId + 1)

# single-line URL to avoid syntax issues
:local url ("https://api.telegram.org/bot" . $BotToken . \
"/getUpdates?offset=" . $offset . "&limit=1")

/tool fetch url=$url mode=https keep-result=yes dst-path=$updatesFile

:local uId [/file find name=$updatesFile]
:if ([:len $uId] = 0) do={
    :put "TG_Step2: ERROR updates file not found after fetch"
    :return
}

:local content [/file get $uId contents]
:put ("TG_Step2: len(tg_updates.txt)=" . [:len $content])
:put ("TG_Step2: content=" . $content)
:put "TG_Step2: END OF SCRIPT"
