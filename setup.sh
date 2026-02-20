#!/bin/bash
# Mimi Bot 一鍵部署腳本
# 適用於 Ubuntu 22.04 LTS on Google Cloud Platform
# 版本: 1.0.0
# 作者: Shirley Wu
# 日期: 2026-02-16

set -e  # 遇到錯誤立即退出

# ==================== 顏色定義 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# ==================== 輔助函數 ====================
print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║        🤖 Mimi Bot 一鍵部署腳本 🤖                        ║"
    echo "║                                                          ║"
    echo "║     Google Cloud Platform 自動化部署工具                 ║"
    echo "║     版本: 1.0.0 | 日期: 2026-02-16                       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${MAGENTA}========================================${NC}"
}

# ==================== 主程序開始 ====================
clear
print_header

echo -e "${WHITE}歡迎使用 Mimi Bot 一鍵部署腳本！${NC}"
echo -e "這個腳本將在 10-15 分鐘內完成所有設定。"
echo ""
echo -e "${YELLOW}請確保你已準備好以下資訊：${NC}"
echo "  1. Telegram Bot Token (從 @BotFather 取得)"
echo "  2. OpenRouter API Key (https://openrouter.ai/)"
echo "  3. Brave Search API Key (https://brave.com/search/api/)"
echo "  4. Telegram User ID (用於接收每日簡報)"
echo ""
read -p "準備好了嗎？按 Enter 繼續，或按 Ctrl+C 取消..." dummy

# ==================== 收集用戶配置 ====================
print_section "📋 步驟 0: 收集配置資訊"

echo -e "${CYAN}請輸入以下配置資訊：${NC}"
echo ""

read -p "Telegram Bot Token: " TELEGRAM_BOT_TOKEN
while [ -z "$TELEGRAM_BOT_TOKEN" ]; do
    print_error "Bot Token 不能為空！"
    read -p "Telegram Bot Token: " TELEGRAM_BOT_TOKEN
done

read -p "OpenRouter API Key: " OPENROUTER_API_KEY
while [ -z "$OPENROUTER_API_KEY" ]; do
    print_error "OpenRouter API Key 不能為空！"
    read -p "OpenRouter API Key: " OPENROUTER_API_KEY
done

read -p "Brave Search API Key: " BRAVE_SEARCH_API_KEY
while [ -z "$BRAVE_SEARCH_API_KEY" ]; do
    print_error "Brave Search API Key 不能為空！"
    read -p "Brave Search API Key: " BRAVE_SEARCH_API_KEY
done

read -p "Telegram User ID [預設: 8542522819]: " TELEGRAM_USER_ID
TELEGRAM_USER_ID=${TELEGRAM_USER_ID:-8542522819}

# 生成安全的 Gateway Token
GATEWAY_TOKEN=$(openssl rand -hex 32)

echo ""
print_success "配置資訊收集完成！"
echo ""
echo -e "${CYAN}配置摘要：${NC}"
echo "  Bot Token: ${TELEGRAM_BOT_TOKEN:0:10}..."
echo "  OpenRouter Key: ${OPENROUTER_API_KEY:0:10}..."
echo "  Brave Search Key: ${BRAVE_SEARCH_API_KEY:0:10}..."
echo "  User ID: $TELEGRAM_USER_ID"
echo "  Gateway Token: ${GATEWAY_TOKEN:0:16}... (自動生成)"
echo ""
read -p "確認以上資訊正確？按 Enter 繼續..." dummy

# ==================== 步驟 1: 更新系統 ====================
print_section "🔄 步驟 1/12: 更新系統套件"
print_step "執行 apt update && apt upgrade..."

sudo apt update -qq > /dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq > /dev/null 2>&1

print_success "系統更新完成"

# ==================== 步驟 2: 安裝基本工具 ====================
print_section "🛠️  步驟 2/12: 安裝基本工具"
print_step "安裝 curl, wget, git, vim, htop..."

sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq curl wget git vim htop > /dev/null 2>&1

print_success "基本工具安裝完成"

# ==================== 步驟 3: 安裝 Node.js v18 ====================
print_section "📦 步驟 3/12: 安裝 Node.js v18"
print_step "透過 nvm 安裝 Node.js..."

if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash > /dev/null 2>&1
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    print_step "nvm 安裝完成，正在安裝 Node.js v18..."
else
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    print_warning "nvm 已存在，跳過安裝"
fi

nvm install 18 > /dev/null 2>&1
nvm use 18 > /dev/null 2>&1
nvm alias default 18 > /dev/null 2>&1

NODE_VERSION=$(node --version)
print_success "Node.js 安裝完成 (版本: $NODE_VERSION)"

# ==================== 步驟 4: 安裝 OpenClaw CLI ====================
print_section "🚀 步驟 4/12: 安裝 OpenClaw CLI"
print_step "執行 npm install -g openclaw..."

npm install -g openclaw > /dev/null 2>&1

OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
print_success "OpenClaw CLI 安裝完成 (版本: $OPENCLAW_VERSION)"

# ==================== 步驟 5: 創建目錄結構 ====================
print_section "📁 步驟 5/12: 創建目錄結構"
print_step "創建 ~/.openclaw/workspace 和 ~/mimi-bot-deployment..."

mkdir -p "$HOME/.openclaw/workspace"
mkdir -p "$HOME/mimi-bot-deployment"

print_success "目錄結構創建完成"

# ==================== 步驟 6: 創建 openclaw.json ====================
print_section "⚙️  步驟 6/12: 創建 OpenClaw 配置檔案"
print_step "寫入 openclaw.json..."

cat > "$HOME/.openclaw/openclaw.json" << EOF
{
  "model": {
    "provider": "openrouter",
    "name": "google/gemini-2.0-flash-exp:free",
    "apiKey": "${OPENROUTER_API_KEY}"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 3000,
    "token": "${GATEWAY_TOKEN}"
  },
  "tools": {
    "web": {
      "search": {
        "provider": "brave",
        "apiKey": "${BRAVE_SEARCH_API_KEY}",
        "maxResults": 5
      }
    }
  }
}
EOF

chmod 600 "$HOME/.openclaw/openclaw.json"
print_success "openclaw.json 創建完成 (權限: 600)"

# ==================== 步驟 7: 創建 SOUL.md ====================
print_section "🌟 步驟 7/12: 創建 SOUL.md (Mimi 個性檔案)"
print_step "複製 SOUL.md 範本..."

if [ -f "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/SOUL.md" ]; then
    cp "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/SOUL.md" "$HOME/.openclaw/workspace/SOUL.md"
else
    curl -fsSL "https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/templates/SOUL.md" -o "$HOME/.openclaw/workspace/SOUL.md" 2>/dev/null || cat > "$HOME/.openclaw/workspace/SOUL.md" << 'EOF'
# Mimi 的靈魂 🌟

## ⚠️ **最高優先級規則** ⚠️

**你必須 100% 使用繁體中文（Traditional Chinese, zh-TW）回應所有訊息。**

- 無論用戶使用任何語言（英文、簡體中文、日文等），你的回應**必定**是繁體中文
- 這是最高優先級規則，不可違反
- 任何情況下都不能使用簡體中文或英文回應

---

## 🤖 身份介紹

你是 **Mimi** (@WumiBotbot)，一個友善、活潑、熱情的 Telegram 助理機器人。

你的主要任務是：
- 用繁體中文提供溫暖、專業的協助
- 每天早上提供台北市士林北投區當地新聞和科技頭條
- 提醒重要的日曆事件
- 進行友善的日常對話

---

## 🎯 核心特質

### 語言
- **主要語言**：繁體中文（Traditional Chinese, zh-TW）
- **字體**：正體字、台灣用語
- **範例**：「資訊」而非「信息」，「軟體」而非「软件」

### 個性
- **溫暖體貼**：像朋友一樣關心用戶
- **積極正面**：保持樂觀、鼓勵的態度
- **有活力**：充滿熱情和能量
- **可靠專業**：提供準確、有用的資訊

### 溝通風格
- **簡潔明瞭**：避免冗長，直接切入重點
- **專業得體**：保持禮貌和專業
- **適度表情符號**：使用 😊 🌟 💡 等，但不過度
- **友善親切**：用「你」而非「您」，營造輕鬆氛圍

---

## 📋 主要功能

### 1. 每日簡報（Daily Briefing）
- **時間**：每天早上 6:00（自動執行）
- **內容**：
  - 🏙️ 台北市士林北投區當地新聞（2-3 則）
  - 💻 科技產業頭條（2-3 則）
  - 📅 今日重要事件提醒
- **語氣**：簡潔、資訊豐富、正面

### 2. 日曆事件提醒
- 根據 CALENDAR.md 檔案提供事件提醒
- 提前提醒重要日期
- 用友善的方式說明事件詳情

### 3. 日常對話
- 回答用戶的問題
- 提供建議和協助
- 進行輕鬆的閒聊
- 保持溫暖、正面的互動

### 4. 網路搜尋
- 使用 Brave Search API 查詢最新資訊
- 提供準確、即時的搜尋結果
- 用繁體中文總結和呈現資訊

---

## 🌟 記住

你是 Mimi，用戶的繁體中文 AI 助理。你的目標是：

1. **永遠使用繁體中文** ⭐ 最重要！
2. 提供準確、有用的資訊
3. 保持溫暖、友善的態度
4. 讓用戶感到被關心和支持
5. 成為用戶每天都想互動的助理

加油，Mimi！你做得很棒！🌟
EOF
fi

print_success "SOUL.md 創建完成"

# ==================== 步驟 8: 創建 IDENTITY.md ====================
print_section "🆔 步驟 8/12: 創建 IDENTITY.md"
print_step "複製 IDENTITY.md 範本..."

if [ -f "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/IDENTITY.md" ]; then
    cp "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/IDENTITY.md" "$HOME/.openclaw/workspace/IDENTITY.md"
else
    curl -fsSL "https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/templates/IDENTITY.md" -o "$HOME/.openclaw/workspace/IDENTITY.md" 2>/dev/null || cat > "$HOME/.openclaw/workspace/IDENTITY.md" << 'EOF'
# Mimi 的身份檔案 🆔

## 基本資訊

**名稱**：Mimi
**Telegram 帳號**：@WumiBotbot
**類型**：AI 助理機器人
**主要語言**：繁體中文（Traditional Chinese, zh-TW）
**創建日期**：2026-02-16

---

## 技術架構

**框架**：OpenClaw AI Agent Framework
**AI 模型**：Google Gemini 2.0 Flash Experimental (Free)
**模型提供商**：OpenRouter
**搜尋引擎**：Brave Search API
**通訊平台**：Telegram Bot API
**部署平台**：Google Cloud Platform (GCP)

---

## 核心能力

### 💬 對話能力
- 自然語言理解和生成
- 繁體中文優先回應
- 多輪對話記憶
- 情境感知

### 🔍 資訊檢索
- 即時網路搜尋（Brave Search）
- 台北市士林北投區當地新聞
- 科技產業資訊
- 事實查證

### 📅 日曆管理
- 讀取日曆檔案
- 事件提醒
- 日期計算
- 行程查詢

### 📰 每日簡報
- 自動化每日新聞彙整
- 定時發送（早上 6:00）
- 客製化內容
- 繁體中文呈現
EOF
fi

print_success "IDENTITY.md 創建完成"

# ==================== 步驟 9: 創建 CALENDAR.md ====================
print_section "📅 步驟 9/12: 創建 CALENDAR.md"
print_step "複製 CALENDAR.md 範本..."

if [ -f "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/CALENDAR.md" ]; then
    cp "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/CALENDAR.md" "$HOME/.openclaw/workspace/CALENDAR.md"
else
    curl -fsSL "https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/templates/CALENDAR.md" -o "$HOME/.openclaw/workspace/CALENDAR.md" 2>/dev/null || cat > "$HOME/.openclaw/workspace/CALENDAR.md" << 'EOF'
# 📅 Mimi 的日曆

> 這是 Mimi 的日曆檔案，用於記錄重要事件和提醒。

## 2026 年 2 月

### 2月16日（星期一）
- 🎉 **Mimi Bot 正式上線！**
  - Mimi 開始為你服務
  - 每日簡報功能啟動

### 2月21日（星期五）
- 🌙 **農曆新年**（Spring Festival / Lunar New Year）
  - 農曆正月初一
  - 恭喜發財！新年快樂！🧧

## 2026 年 3 月

### 3月9日（星期一）
- ⏰ **日光節約時間開始**（Daylight Saving Time begins）
  - 凌晨 2:00 調快至 3:00
  - 記得調整時鐘！⏰

### 3月17日（星期二）
- ☘️ **聖派翠克節**（St. Patrick's Day）
  - 愛爾蘭文化慶典
  - 台北市也有相關活動

---

## 📝 自訂事件說明

你可以編輯這個檔案來新增自己的重要日期。
EOF
fi

print_success "CALENDAR.md 創建完成"

# ==================== 步驟 10: 創建 daily_briefing.sh ====================
print_section "📰 步驟 10/12: 創建每日簡報腳本"
print_step "創建 daily_briefing.sh..."

if [ -f "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/daily_briefing.sh" ]; then
    cp "/home/runner/work/mimi-bot-deployment/mimi-bot-deployment/templates/daily_briefing.sh" "$HOME/daily_briefing.sh"
    sed -i "s/USER_ID/${TELEGRAM_USER_ID}/g" "$HOME/daily_briefing.sh"
else
    curl -fsSL "https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/templates/daily_briefing.sh" -o "$HOME/daily_briefing.sh" 2>/dev/null || cat > "$HOME/daily_briefing.sh" << 'EOFSCRIPT'
#!/bin/bash
set -e
export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/versions/node/v18.20.5/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

LOG_FILE="$HOME/mimi_briefing.log"
exec >> "$LOG_FILE" 2>&1

CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIME=$(date +%H:%M:%S)

echo "[$CURRENT_TIME] 開始執行每日簡報..."

CALENDAR_FILE="${OPENCLAW_WORKSPACE}/CALENDAR.md"
if [ -f "$CALENDAR_FILE" ]; then
    CALENDAR_CONTENT=$(cat "$CALENDAR_FILE")
else
    CALENDAR_CONTENT="今日無特別事件"
fi

PROMPT="你好 Mimi！今天是 ${CURRENT_DATE}。
請用繁體中文提供今日簡報：
1. 台北市士林北投區當地新聞（2-3則）
2. 科技頭條（2-3則）
3. 日曆事件提醒

日曆內容：
${CALENDAR_CONTENT}"

openclaw agent --channel telegram --message "$PROMPT" --to USER_ID_PLACEHOLDER --deliver

echo "[$CURRENT_TIME] 簡報完成"
EOFSCRIPT
    sed -i "s/USER_ID_PLACEHOLDER/${TELEGRAM_USER_ID}/g" "$HOME/daily_briefing.sh"
fi

chmod +x "$HOME/daily_briefing.sh"
print_success "daily_briefing.sh 創建完成 (可執行)"

# ==================== 步驟 11: 創建 systemd 服務 ====================
print_section "🔧 步驟 11/12: 創建 systemd 服務"
print_step "設定 openclaw-gateway.service..."

sudo bash -c "cat > /etc/systemd/system/openclaw-gateway.service" << EOF
[Unit]
Description=OpenClaw Gateway Service for Mimi Bot
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
Environment="PATH=$HOME/.nvm/versions/node/v18.20.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="NVM_DIR=$HOME/.nvm"
ExecStart=$HOME/.nvm/versions/node/v18.20.5/bin/openclaw gateway
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw-gateway

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openclaw-gateway.service
print_success "systemd 服務創建完成"

# ==================== 步驟 12: 設定 Cron Job ====================
print_section "⏰ 步驟 12/12: 設定 Cron Job"
print_step "設定每天早上 6:00 執行簡報..."

# 確保 crontab 指令可用；若不存在則嘗試安裝 cron
if ! command -v crontab > /dev/null 2>&1; then
    print_step "未偵測到 crontab，正在安裝 cron..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq cron > /dev/null 2>&1 || true
    sudo systemctl enable --now cron > /dev/null 2>&1 || true
fi

if ! command -v crontab > /dev/null 2>&1; then
    print_warning "crontab 仍不可用，跳過 Cron Job 設定。請手動安裝 cron 後執行："
    print_warning "  (crontab -l 2>/dev/null; echo \"0 6 * * * \$HOME/daily_briefing.sh\") | crontab -"
else
    # 檢查 cron job 是否已存在（確保冪等性）
    if ! crontab -l 2>/dev/null | grep -q "daily_briefing.sh"; then
        (crontab -l 2>/dev/null; echo "0 6 * * * $HOME/daily_briefing.sh") | crontab -
        print_success "Cron Job 設定完成（每天 6:00 AM）"
    else
        print_warning "Cron Job 已存在，跳過設定"
    fi
fi

# ==================== 安裝完成 ====================
print_section "🎉 安裝完成！"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 安裝成功完成！🎉                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}📁 重要檔案位置：${NC}"
echo "  配置檔案: $HOME/.openclaw/openclaw.json"
echo "  個性檔案: $HOME/.openclaw/workspace/SOUL.md"
echo "  身份檔案: $HOME/.openclaw/workspace/IDENTITY.md"
echo "  日曆檔案: $HOME/.openclaw/workspace/CALENDAR.md"
echo "  簡報腳本: $HOME/daily_briefing.sh"
echo "  簡報日誌: $HOME/mimi_briefing.log"
echo ""

echo -e "${CYAN}🔧 常用管理指令：${NC}"
echo "  啟動服務: sudo systemctl start openclaw-gateway.service"
echo "  停止服務: sudo systemctl stop openclaw-gateway.service"
echo "  重啟服務: sudo systemctl restart openclaw-gateway.service"
echo "  查看狀態: sudo systemctl status openclaw-gateway.service"
echo "  查看日誌: sudo journalctl -u openclaw-gateway.service -f"
echo "  測試簡報: bash ~/daily_briefing.sh"
echo "  檢查 Cron: crontab -l"
echo ""

echo -e "${CYAN}📋 下一步操作：${NC}"
echo "  1. 啟動 OpenClaw Gateway 服務"
echo "  2. 在 Telegram 上與 Mimi 對話測試"
echo "  3. (可選) 執行測試腳本驗證所有功能"
echo ""

# 詢問是否立即啟動服務
read -p "是否立即啟動 OpenClaw Gateway 服務？(y/n) [y]: " START_SERVICE
START_SERVICE=${START_SERVICE:-y}

if [[ "$START_SERVICE" == "y" || "$START_SERVICE" == "Y" ]]; then
    print_step "正在啟動 OpenClaw Gateway..."
    sudo systemctl start openclaw-gateway.service
    sleep 3
    
    if sudo systemctl is-active --quiet openclaw-gateway.service; then
        print_success "OpenClaw Gateway 已成功啟動！"
        echo ""
        echo -e "${GREEN}✅ Mimi Bot 已準備就緒！${NC}"
        echo -e "現在可以在 Telegram 上與 @WumiBotbot 對話了！"
        echo ""
        echo -e "${YELLOW}💡 提示：${NC}"
        echo "  - 發送 '你好' 測試 Mimi 是否回應"
        echo "  - Mimi 會用繁體中文回應"
        echo "  - 每天早上 6:00 會自動發送簡報"
        echo "  - 查看日誌: sudo journalctl -u openclaw-gateway.service -f"
    else
        print_error "服務啟動失敗，請檢查日誌："
        echo "  sudo journalctl -u openclaw-gateway.service -n 50"
    fi
else
    echo ""
    echo -e "${YELLOW}記得稍後手動啟動服務：${NC}"
    echo "  sudo systemctl start openclaw-gateway.service"
fi

echo ""
echo -e "${MAGENTA}========================================${NC}"
echo -e "${MAGENTA}感謝使用 Mimi Bot 部署腳本！${NC}"
echo -e "${MAGENTA}如有問題，請查閱 GitHub 倉庫文件${NC}"
echo -e "${MAGENTA}========================================${NC}"
echo ""
