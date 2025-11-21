:local BotToken "<BotToken>";
:local ChatID "<ChatID>";
:local ParseMode "html";
:local DisableWebPagePreview True;
:local SendText $MessageText;

:local tgUrl "https://api.telegram.org/bot$BotToken/sendMessage\?chat_id=$ChatID&text=$SendText&parse_mode=$ParseMode&disable_web_page_preview=$DisableWebPagePreview";

/tool fetch http-method=get url=$tgUrl output=none;