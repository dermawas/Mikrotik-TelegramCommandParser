# TG_Step1_StateFile (flash-persistent version)
# Goal: ensure flash/tg_lastupdateid.txt exists AND contains "0"

:local stateFile "flash/tg_lastupdateid.txt"

# Check if the file already exists
:local fId [/file find name=$stateFile]

:if ([:len $fId] = 0) do={
    :put ("TG_Step1_StateFile: state file not found, creating " . $stateFile)
    # Create the file (RouterOS creates it via /file print)
    /file print file=$stateFile
    :set fId [/file find name=$stateFile]
}

# Now force its contents to "0"
:file set $fId contents="0"

:log info ("TG_Step1_StateFile: wrote '0' to " . $stateFile)
:put ("TG_Step1_StateFile: OK, state reset to 0 in " . $stateFile)
