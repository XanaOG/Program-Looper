#!/bin/bash

session_name="Main-Email-Bot"
lock_file="/tmp/Program.lock"
discord_webhook="Webhook"
root_path="Program-Path"
program_name="Program-Name"

if [ -f "$lock_file" ]; then
    echo "Session $session_name is already running. Exiting."
    exit 1
fi

send_discord_message() {
    local message="$1"
    local title="$2"
    local color="$3"
    local author_name="Username"
    local author_icon="Author Logo"
    local footer_text="\nFooter\nText"

    payload=$(cat <<EOF
{
  "content": null,
  "embeds": [
    {
      "title": "$title",
      "description": "$message",
      "color": $color,
      "author": {
        "name": "$author_name",
        "icon_url": "$author_icon"
      },
      "footer": {
        "text": "$footer_text"
      }
    }
  ]
}
EOF
)

    curl -H "Content-Type: application/json" -X POST -d "$payload" "$discord_webhook"
}

touch "$lock_file"

if screen -ls | grep -q "$session_name"; then
    echo "Session $session_name is already running."
    send_discord_message "Session $session_name is still active." "Session Status" 65280
else
    echo "Session $session_name is not running. Starting a new session."
    send_discord_message "Starting a new session: $session_name." "Session Started" 4710558
    cd $root_path/
    rm -rf $root_path/screenlog.0
    screen -dmS "$session_name" ./$program_name
fi

while true; do
    sleep 1
    if ! screen -ls | grep -q "$session_name"; then
        echo "Session $session_name has crashed. Restarting the session."
        send_discord_message "Session $session_name has crashed. Restarting the session." "Session Crashed" 15158332
        cd $root_path/
        rm -rf $root_path/screenlog.0
        screen -dmS "$session_name" ./$program_name
    fi
done

rm "$lock_file"
