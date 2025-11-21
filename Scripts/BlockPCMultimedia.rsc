#Toggle IP Control
/ip kid-control enable "PC-Multimedia"

#Wait 1 second before sending
:delay 1;

#Send Notif to telegram
:local DeviceName [/system identity get name];

:local MessageText "%F0%9F%A4%96 <b>$DeviceName:%E2%9A%A0 <u>PCMultimedia Kid </u>is BLOCKED</b>";

#get TGBotSenderScript to send
:local SendTelegramMessage [:parse [/system script  get TGBotSenderScript source]];

$SendTelegramMessage MessageText=$MessageText;