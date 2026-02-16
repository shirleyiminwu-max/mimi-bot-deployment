#!/bin/bash
# Mimi Bot 每日簡報腳本
# 此腳本由 cron 每天早上 6:00 執行
# 功能：發送包含舊金山新聞、科技頭條和日曆事件的每日簡報

set -e  # 遇到錯誤立即退出

# ==================== 環境設定 ====================
export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/versions/node/v18.20.5/bin:$PATH"

# 載入 nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ==================== 日誌設定 ====================
LOG_FILE="$HOME/mimi_briefing.log"
exec >> "$LOG_FILE" 2>&1

# ==================== 時間資訊 ====================
CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIME=$(date +%H:%M:%S)
WEEKDAY=$(date +%A)

echo "=========================================="
echo "[$CURRENT_TIME] 🌅 開始執行每日簡報"
echo "日期: $CURRENT_DATE ($WEEKDAY)"
echo "=========================================="

# ==================== 讀取日曆 ====================
CALENDAR_FILE="${OPENCLAW_WORKSPACE}/CALENDAR.md"
if [ -f "$CALENDAR_FILE" ]; then
    echo "[$CURRENT_TIME] ✅ 找到日曆檔案: $CALENDAR_FILE"
    CALENDAR_CONTENT=$(cat "$CALENDAR_FILE")
else
    echo "[$CURRENT_TIME] ⚠️  日曆檔案不存在，使用預設訊息"
    CALENDAR_CONTENT="今日無特別事件"
fi

# ==================== 建立簡報提示詞 ====================
PROMPT="你好 Mimi！今天是 ${CURRENT_DATE}（${WEEKDAY}）。

請用繁體中文提供今日簡報，格式如下：

🌅 **早安！今天是 ${CURRENT_DATE}**

🌁 **舊金山當地新聞**（2-3 則最新消息）
[使用 web search 搜尋 San Francisco local news]

💻 **科技產業頭條**（2-3 則重要新聞）
[使用 web search 搜尋 tech news technology headlines]

📅 **今日重要事件**
[根據以下日曆內容提醒]

---
日曆內容：
${CALENDAR_CONTENT}
---

請保持簡潔、資訊豐富，適度使用表情符號。
記得：必須 100% 使用繁體中文！"

echo "[$CURRENT_TIME] 📝 簡報提示詞已準備"

# ==================== 檢查 OpenClaw CLI ====================
if ! command -v openclaw &> /dev/null; then
    echo "[$CURRENT_TIME] ❌ 錯誤: 找不到 openclaw 指令"
    echo "[$CURRENT_TIME] 請確認 OpenClaw 已正確安裝並在 PATH 中"
    exit 1
fi

echo "[$CURRENT_TIME] ✅ OpenClaw CLI 已就緒"

# ==================== 發送簡報 ====================
echo "[$CURRENT_TIME] 🚀 開始發送簡報..."

# 注意：USER_ID 將在 setup.sh 執行時被替換為實際的 Telegram User ID
if openclaw agent --channel telegram --message "$PROMPT" --to USER_ID --deliver; then
    echo "[$CURRENT_TIME] ✅ 簡報發送成功！"
    echo "=========================================="
    echo "[$CURRENT_TIME] 🎉 每日簡報完成"
    echo "=========================================="
    exit 0
else
    echo "[$CURRENT_TIME] ❌ 簡報發送失敗"
    echo "[$CURRENT_TIME] 請檢查日誌: $LOG_FILE"
    echo "[$CURRENT_TIME] 檢查項目："
    echo "  1. OpenClaw Gateway 服務是否運行"
    echo "  2. Telegram Bot Token 是否正確"
    echo "  3. User ID 是否正確"
    echo "  4. 網路連線是否正常"
    exit 1
fi
