```bash
hf download bartowski/mistralai_Devstral-Small-2-24B-Instruct-2512-GGUF mistralai_Devstral-Small-2-24B-Instruct-2512-Q8_0.gguf --local-dir /usr/local/models


launchctl bootstrap system /Library/LaunchDaemons/qwen3.plist
launchctl bootstrap system /Library/LaunchDaemons/devstral.plist
launchctl bootstrap system /Library/LaunchDaemons/devstral-2.plist
```