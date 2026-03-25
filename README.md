# code-assistant-sandbox
Sandbox project for experimenting with privately hosted code assistants.

```bash
brew install llama.cpp
```



```bash
cat << EOF > /Library/LaunchDaemons/llama-server.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.cpp.llama</string>
    <key>ProgramArguments</key>
      <array>
        <string>/opt/homebrew/bin/llama-server</string>
        <string>--model</string>
        <string>/usr/local/models/devstral:24b</string>
        <string>--host</string>
        <string>0.0.0.0</string>
        <string>--n-gpu-layers</string>
        <string>999</string>
        <string>--flash-attn</string>
        <string>--ctx-size</string>
        <string>131072</string>
        <string>--jinja</string>
        <string>--no-prefill-assistant</string>
        <string>--reasoning-format</string>
        <string>none</string>
      </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/llama-server/llama-cpp.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/llama-server/llama-cpp.log</string>
  </dict>
</plist>
EOF

launchctl remove system/qwen3-next

launchctl bootstrap system /Library/LaunchDaemons/llama-server-qwen3-next.plist
```

llama-server --model ./models/devstral:24b --host 0.0.0.0 --n-gpu-layers 999 --flash-attn --ctx-size 131072 --jinja --no-prefill-assistant --verbose --reasoning-format none

hf download Qwen/Qwen3-Coder-Next-GGUF Qwen3-Coder-Next-Q5_K_M/Qwen3-Coder-Next-Q5_K_M-00001-of-00004.gguf --local-dir /usr/local/models

llama-server --model /usr/local/models/Qwen3-Coder-Next-Q5_K_M/Qwen3-Coder-Next-Q5_K_M-00001-of-00004.gguf --host 0.0.0.0 --n-gpu-layers 999 --ctx-size 262144 --jinja 