#!/bin/bash
# Mimi Bot 系統測試腳本
# 檢查所有關鍵元件是否正確安裝和配置
# 版本: 1.0.0

# ==================== 顏色定義 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ==================== 測試計數器 ====================
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# ==================== 輔助函數 ====================
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          🧪 Mimi Bot 系統測試腳本 🧪                      ║"
    echo "║                                                          ║"
    echo "║     驗證所有關鍵元件是否正確安裝和配置                   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

test_start() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}[測試 $TOTAL_TESTS]${NC} $1"
}

test_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}  ✅ PASS:${NC} $1"
    echo ""
}

test_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}  ❌ FAIL:${NC} $1"
    echo ""
}

test_info() {
    echo -e "${CYAN}  ℹ️  INFO:${NC} $1"
}

# ==================== 主程序開始 ====================
print_header

echo -e "${WHITE}開始進行系統檢查...${NC}"
echo ""

# ==================== 測試 1: Node.js 版本 ====================
test_start "檢查 Node.js 安裝"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    test_info "Node.js 版本: $NODE_VERSION"
    
    if [[ "$NODE_VERSION" == v18.* ]]; then
        test_pass "Node.js v18 已正確安裝"
    else
        test_fail "Node.js 版本不是 v18 (當前: $NODE_VERSION)"
    fi
else
    test_fail "Node.js 未安裝或不在 PATH 中"
fi

# ==================== 測試 2: OpenClaw CLI ====================
test_start "檢查 OpenClaw CLI"

if command -v openclaw &> /dev/null; then
    OPENCLAW_VERSION=$(openclaw --version 2>&1 || echo "無法取得版本")
    test_info "OpenClaw 版本: $OPENCLAW_VERSION"
    test_pass "OpenClaw CLI 已安裝"
else
    test_fail "OpenClaw CLI 未安裝"
fi

# ==================== 測試 3: 配置檔案 ====================
test_start "檢查 openclaw.json 配置檔案"

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
    test_info "配置檔案位置: $CONFIG_FILE"
    
    # 檢查檔案權限
    FILE_PERMS=$(stat -c "%a" "$CONFIG_FILE" 2>/dev/null || stat -f "%A" "$CONFIG_FILE" 2>/dev/null)
    test_info "檔案權限: $FILE_PERMS"
    
    # 檢查必要欄位
    MISSING_FIELDS=""
    
    if ! grep -q '"provider"' "$CONFIG_FILE"; then
        MISSING_FIELDS="${MISSING_FIELDS}provider, "
    fi
    
    if ! grep -q '"botToken"' "$CONFIG_FILE"; then
        MISSING_FIELDS="${MISSING_FIELDS}botToken, "
    fi
    
    if ! grep -q '"apiKey"' "$CONFIG_FILE"; then
        MISSING_FIELDS="${MISSING_FIELDS}apiKey, "
    fi
    
    if [ -z "$MISSING_FIELDS" ]; then
        test_pass "openclaw.json 格式正確，包含所有必要欄位"
    else
        test_fail "openclaw.json 缺少欄位: ${MISSING_FIELDS%, }"
    fi
else
    test_fail "openclaw.json 不存在於 $CONFIG_FILE"
fi

# ==================== 測試 4: SOUL.md ====================
test_start "檢查 SOUL.md (Mimi 個性檔案)"

SOUL_FILE="$HOME/.openclaw/workspace/SOUL.md"
if [ -f "$SOUL_FILE" ]; then
    test_info "SOUL.md 位置: $SOUL_FILE"
    
    # 檢查是否包含繁體中文規則
    if grep -q "繁體中文" "$SOUL_FILE"; then
        test_info "包含繁體中文規則 ✓"
        test_pass "SOUL.md 已正確創建"
    else
        test_fail "SOUL.md 存在但缺少繁體中文規則"
    fi
else
    test_fail "SOUL.md 不存在於 $SOUL_FILE"
fi

# ==================== 測試 5: 每日簡報腳本 ====================
test_start "檢查每日簡報腳本"

BRIEFING_SCRIPT="$HOME/daily_briefing.sh"
if [ -f "$BRIEFING_SCRIPT" ]; then
    test_info "腳本位置: $BRIEFING_SCRIPT"
    
    # 檢查是否可執行
    if [ -x "$BRIEFING_SCRIPT" ]; then
        test_info "腳本具有執行權限 ✓"
        
        # 檢查是否包含必要元素
        if grep -q "openclaw agent" "$BRIEFING_SCRIPT"; then
            test_pass "daily_briefing.sh 已正確配置"
        else
            test_fail "daily_briefing.sh 缺少 openclaw agent 命令"
        fi
    else
        test_fail "daily_briefing.sh 沒有執行權限"
    fi
else
    test_fail "daily_briefing.sh 不存在於 $BRIEFING_SCRIPT"
fi

# ==================== 測試 6: systemd 服務 ====================
test_start "檢查 systemd 服務"

SERVICE_FILE="/etc/systemd/system/openclaw-gateway.service"
if [ -f "$SERVICE_FILE" ]; then
    test_info "服務檔案: $SERVICE_FILE"
    
    # 檢查服務狀態
    if sudo systemctl is-enabled openclaw-gateway.service &> /dev/null; then
        test_info "服務已設為開機啟動 ✓"
    else
        test_info "服務未設為開機啟動"
    fi
    
    # 檢查服務是否運行中
    if sudo systemctl is-active openclaw-gateway.service &> /dev/null; then
        test_info "服務狀態: 運行中 ✓"
        test_pass "openclaw-gateway.service 已正確配置並運行"
    else
        test_info "服務狀態: 未運行"
        test_pass "openclaw-gateway.service 已配置（但未運行）"
    fi
else
    test_fail "openclaw-gateway.service 不存在"
fi

# ==================== 測試 7: Cron Job ====================
test_start "檢查 Cron Job"

if crontab -l 2>/dev/null | grep -q "daily_briefing.sh"; then
    CRON_LINE=$(crontab -l 2>/dev/null | grep "daily_briefing.sh")
    test_info "Cron 規則: $CRON_LINE"
    
    if echo "$CRON_LINE" | grep -q "^0 6"; then
        test_pass "Cron Job 已正確設定（每天 6:00 AM）"
    else
        test_fail "Cron Job 存在但時間設定可能不正確"
    fi
else
    test_fail "未找到 daily_briefing.sh 的 Cron Job"
fi

# ==================== 測試摘要 ====================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   📊 測試結果摘要                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "總測試數: ${WHITE}$TOTAL_TESTS${NC}"
echo -e "通過: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失敗: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✅ 所有測試通過！系統運作正常！✅                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🎉 Mimi Bot 已準備就緒！${NC}"
    echo ""
    echo -e "${WHITE}下一步：${NC}"
    echo "  1. 在 Telegram 上與 @WumiBotbot 對話"
    echo "  2. 發送 '你好' 測試回應"
    echo "  3. 確認 Mimi 使用繁體中文回應"
    echo "  4. 等待明天早上 6:00 接收每日簡報"
    echo ""
    echo -e "${YELLOW}管理指令：${NC}"
    echo "  查看服務狀態: sudo systemctl status openclaw-gateway.service"
    echo "  查看即時日誌: sudo journalctl -u openclaw-gateway.service -f"
    echo "  手動執行簡報: bash ~/daily_briefing.sh"
    echo ""
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║       ⚠️  發現 $FAILED_TESTS 個問題，請檢查並修復  ⚠️            ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}建議動作：${NC}"
    echo "  1. 檢查上方失敗的測試項目"
    echo "  2. 參考 TROUBLESHOOTING.md 故障排除指南"
    echo "  3. 查看安裝日誌確認錯誤訊息"
    echo "  4. 如需要，重新執行 setup.sh"
    echo ""
    echo -e "${CYAN}需要協助？${NC}"
    echo "  GitHub Issues: https://github.com/shirleyiminwu-max/mimi-bot-deployment/issues"
    echo ""
    exit 1
fi
