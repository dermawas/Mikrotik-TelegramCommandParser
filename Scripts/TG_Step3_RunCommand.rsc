# TG_Step3_RunCommand - minimal version with safe "no new updates" handling
# Commands:
#   !BlockXxx / !UnblockXxx / !BlockAll / !UnblockAll

:local ChatID "<ChatID>"
:local stateFile "flash/tg_lastupdateid.txt"
:local updatesFile "flash/tg_updates.txt"

# 0) Load updates file
:local uId [/file find name=$updatesFile]
:if ([:len $uId] = 0) do={
    :put "TG_Step3: updates file missing"
    :put "TG_Step3: END OF SCRIPT"
    :return
}

:local content [/file get $uId contents]
:put ("TG_Step3: len(tg_updates.txt)=" . [:len $content])

# --- NEW: handle result:[] cleanly -------------------------------
# If there is no "update_id" at all, Telegram returned: {"ok":true,"result":[]}
:if ([:find $content "\"update_id\":" ] = nil) do={
    :put "TG_Step3: no update_id in file (no new updates)"
    :put "TG_Step3: END OF SCRIPT"
    :return
}
# -----------------------------------------------------------------

# 1) Parse update_id
:local keyUpdate "\"update_id\":"
:local posUpdate [:find $content $keyUpdate]

:if ($posUpdate = nil) do={
    :put "TG_Step3: update_id not found"
    :put "TG_Step3: END OF SCRIPT"
    :return
}

:local idStart ($posUpdate + [:len $keyUpdate])
:local idEnd $idStart
:local done false

:while (($idEnd < [:len $content]) && ($done = false)) do={
    :local c [:pick $content $idEnd ($idEnd + 1)]
    :if ($c ~ "[0-9]") do={
        :set idEnd ($idEnd + 1)
    } else={
        :set done true
    }
}

:local updateId [:pick $content $idStart $idEnd]
:put ("TG_Step3: update_id=" . $updateId)

:if ([:len $updateId] = 0) do={
    :put "TG_Step3: updateId empty, abort"
    :put "TG_Step3: END OF SCRIPT"
    :return
}

# 2) Parse chat_id (optional)
:local chatId ""
:local keyChat "\"chat\":{\"id\":"
:local posChat [:find $content $keyChat]

:if ($posChat != nil) do={
    :local cStart ($posChat + [:len $keyChat])
    :local cEnd $cStart
    :set done false

    :while (($cEnd < [:len $content]) && ($done = false)) do={
        :local c [:pick $content $cEnd ($cEnd + 1)]
        :if (($c = "-") && ($cEnd = $cStart)) do={
            :set cEnd ($cEnd + 1)
        } else={
            :if ($c ~ "[0-9]") do={
                :set cEnd ($cEnd + 1)
            } else={
                :set done true
            }
        }
    }

    :set chatId [:pick $content $cStart $cEnd]
}

:put ("TG_Step3: chatId=" . $chatId)

# 3) Parse text (message)
:local msgText ""
:local keyText "\"text\":\""
:local posText [:find $content $keyText]

:if ($posText != nil) do={
    :local tStart ($posText + [:len $keyText])
    :local tEnd $tStart
    :set done false

    :while (($tEnd < [:len $content]) && ($done = false)) do={
        :local c [:pick $content $tEnd ($tEnd + 1)]
        :if ($c = "\"") do={
            :if ([:pick $content ($tEnd - 1) $tEnd] != "\\") do={
                :set done true
            } else={
                :set tEnd ($tEnd + 1)
            }
        } else={
            :set tEnd ($tEnd + 1)
        }
    }

    :set msgText [:pick $content $tStart $tEnd]
}

:put ("TG_Step3: msgText=" . $msgText)

# 4) Decide scriptName (only same chat + !command)
:local scriptName ""
:local runScript false

:if ($chatId = $ChatID) do={
    :if (([:len $msgText] > 0) && ([:pick $msgText 0 1] = "!")) do={

        :set scriptName [:pick $msgText 1 [:len $msgText]]

        # trim spaces
        :while (([:len $scriptName] > 0) && ([:pick $scriptName 0 1] = " ")) do={
            :set scriptName [:pick $scriptName 1 [:len $scriptName]]
        }
        :while (([:len $scriptName] > 0) && ([:pick $scriptName (([:len $scriptName] - 1)) [:len $scriptName]] = " ")) do={
            :set scriptName [:pick $scriptName 0 (([:len $scriptName] - 1))]
        }

        :put ("TG_Step3: scriptName=" . $scriptName)

        :if ([:len $scriptName] > 0) do={
            :local scId [/system script find name=$scriptName]
            :if ([:len $scId] > 0) do={
                :set runScript true
            } else={
                :put ("TG_Step3: script not found: " . $scriptName)
            }
        }
    } else={
        :put "TG_Step3: from our chat but not a !command"
    }
} else={
    :put "TG_Step3: message from other chat or chatId missing, ignored"
}

# 5) Run script if found
:if ($runScript = true) do={
    :do {
        /system script run $scriptName
        :put ("TG_Step3: executed " . $scriptName)
    } on-error={
        :put ("TG_Step3: ERROR running script: " . $reason)
    }
}

# 6) Update state file (always, once we have a valid updateId)
:local sId [/file find name=$stateFile]
:if ([:len $sId] = 0) do={
    /file print file=$stateFile
    :set sId [/file find name=$stateFile]
}

/file set $sId contents=$updateId
:put ("TG_Step3: state updated OK (" . $updateId . ")")
:put "TG_Step3: END OF SCRIPT"
