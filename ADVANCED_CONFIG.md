# 🔧 Mimi Bot 進階配置指南

本指南介紹如何自訂和優化 Mimi Bot 的功能。

## 目錄

1. [自訂 Mimi 個性](#自訂-mimi-個性)
2. [調整簡報內容和時間](#調整簡報內容和時間)
3. [更換 AI 模型](#更換-ai-模型)
4. [設定多個提醒時間](#設定多個提醒時間)
5. [整合其他服務](#整合其他服務)
6. [備份與還原](#備份與還原)
7. [監控與告警](#監控與告警)
8. [效能優化](#效能優化)

---

## 自訂 Mimi 個性

### 修改 SOUL.md

SOUL.md 定義了 Mimi 的個性、語氣和行為準則。

**編輯檔案**：
```bash
nano ~/.openclaw/workspace/SOUL.md
```

### 個性化範例

#### 範例 1：更專業的語氣

在 SOUL.md 中加入：

```markdown
### 專業模式
- 使用正式用語
- 避免表情符號（僅在特殊情況使用）
- 提供詳細、結構化的回應
- 引用來源和數據支持論點
```

#### 範例 2：更活潑的風格

```markdown
### 活潑模式
- 多使用表情符號 😊 🎉 ✨
- 用輕鬆、幽默的語氣
- 加入流行語和網路用語
- 保持對話互動性
```

#### 範例 3：特定領域專家

```markdown
### 科技產業專家
- 專注於科技、創業、AI 話題
- 提供深入的技術分析
- 分享產業趨勢和洞察
- 使用專業術語並解釋給一般用戶理解
```

### 語言和風格調整

#### 調整稱呼方式

**預設**：使用「你」
```markdown
你好！有什麼我可以幫你的？
```

**正式版**：使用「您」
```markdown
您好！有什麼我可以為您服務的？
```

在 SOUL.md 中指定：
```markdown
### 溝通風格
- **稱呼**：使用「您」表示尊重
- **語氣**：正式、專業
```

#### 調整回應長度

**簡潔模式**：
```markdown
## 回應原則
- 每則回應不超過 3 句話（除非用戶要求詳細說明）
- 直接回答問題，避免冗長
- 提供要點而非段落
```

**詳細模式**：
```markdown
## 回應原則
- 提供完整、詳細的回應
- 包含背景資訊和解釋
- 舉例說明
- 總結要點
```

---

## 調整簡報內容和時間

### 修改簡報時間

**預設**：每天早上 6:00

**修改為其他時間**：

```bash
crontab -e
```

修改時間（Cron 格式）：

| 時間 | Cron 表達式 | 說明 |
|------|------------|------|
| 早上 7:00 | `0 7 * * *` | 工作日可能更合適 |
| 早上 8:30 | `30 8 * * *` | 起床後的最佳時間 |
| 晚上 8:00 | `0 20 * * *` | 晚間簡報 |
| 僅工作日 7:00 | `0 7 * * 1-5` | 週一到週五 |
| 週末 9:00 | `0 9 * * 0,6` | 週六和週日 |

**範例**：工作日早上 7:30，週末 9:00

```cron
30 7 * * 1-5 /home/user/daily_briefing.sh
0 9 * * 0,6 /home/user/daily_briefing.sh
```

### 自訂簡報內容

編輯 `daily_briefing.sh`：

```bash
nano ~/daily_briefing.sh
```

#### 範例 1：加入天氣預報

修改 PROMPT 部分：

```bash
PROMPT="你好 Mimi！今天是 ${CURRENT_DATE}（${WEEKDAY}）。

請用繁體中文提供今日簡報，格式如下：

🌅 **早安！今天是 ${CURRENT_DATE}**

🌤️ **舊金山今日天氣**
[搜尋 San Francisco weather today]

🌁 **舊金山當地新聞**（2-3 則）
[搜尋 San Francisco local news]

💻 **科技產業頭條**（2-3 則）
[搜尋 tech news technology headlines]

📅 **今日重要事件**
[根據日曆內容提醒]

日曆內容：
${CALENDAR_CONTENT}"
```

#### 範例 2：加入股票資訊

```bash
PROMPT="你好 Mimi！今天是 ${CURRENT_DATE}。

請用繁體中文提供今日簡報：

📈 **美股市場概況**
[搜尋 US stock market today Nasdaq S&P500]

💻 **科技頭條**（2-3 則）

📅 **今日事件**

日曆：${CALENDAR_CONTENT}"
```

#### 範例 3：簡化版（僅新聞）

```bash
PROMPT="今天是 ${CURRENT_DATE}。請用繁體中文提供 3 則舊金山最新新聞，簡潔呈現。"
```

### 建立多個簡報腳本

**早報**（news_morning.sh）：
```bash
cp ~/daily_briefing.sh ~/news_morning.sh
nano ~/news_morning.sh
# 修改 PROMPT 為早間新聞
```

**晚報**（news_evening.sh）：
```bash
cp ~/daily_briefing.sh ~/news_evening.sh
nano ~/news_evening.sh
# 修改 PROMPT 為當天回顧
```

**設定 Cron**：
```cron
0 7 * * * /home/user/news_morning.sh   # 早上 7:00
0 20 * * * /home/user/news_evening.sh  # 晚上 8:00
```

---

## 更換 AI 模型

### OpenRouter 支援的模型

編輯配置檔案：
```bash
nano ~/.openclaw/openclaw.json
```

#### 推薦的免費模型

**Google Gemini 2.0 Flash**（預設）：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "google/gemini-2.0-flash-exp:free",
    "apiKey": "your-key"
  }
}
```

**Google Gemini Pro**：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "google/gemini-pro",
    "apiKey": "your-key"
  }
}
```

#### 付費模型（更強大）

**Claude 3.5 Sonnet**：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "anthropic/claude-3.5-sonnet",
    "apiKey": "your-key"
  }
}
```

**GPT-4**：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "openai/gpt-4-turbo",
    "apiKey": "your-key"
  }
}
```

**重啟服務**：
```bash
sudo systemctl restart openclaw-gateway.service
```

### 模型選擇建議

| 模型 | 適用場景 | 成本 | 速度 |
|------|---------|------|------|
| Gemini 2.0 Flash | 日常對話、簡報 | 免費 | ⚡⚡⚡ 快 |
| Claude 3 Haiku | 快速回應 | 低 | ⚡⚡⚡ 快 |
| Claude 3.5 Sonnet | 複雜任務、深度分析 | 中 | ⚡⚡ 中等 |
| GPT-4 Turbo | 最高品質回應 | 高 | ⚡ 較慢 |

---

## 設定多個提醒時間

### 建立提醒腳本

**創建 reminders.sh**：

```bash
nano ~/reminders.sh
```

內容：

```bash
#!/bin/bash
set -e

export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
export NVM_DIR="$HOME/.nvm"
export PATH="$NVM_DIR/versions/node/v18.20.5/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

CURRENT_TIME=$(date +%H:%M)
CURRENT_DATE=$(date +%Y-%m-%d)

# 讀取日曆
CALENDAR_FILE="${OPENCLAW_WORKSPACE}/CALENDAR.md"
if [ -f "$CALENDAR_FILE" ]; then
    CALENDAR_CONTENT=$(cat "$CALENDAR_FILE")
else
    CALENDAR_CONTENT="今日無事件"
fi

# 根據時間發送不同提醒
case "$1" in
    morning)
        MESSAGE="早安！☀️ 今天是 ${CURRENT_DATE}。今日行程：\n${CALENDAR_CONTENT}"
        ;;
    noon)
        MESSAGE="午安！🍽️ 記得吃午餐休息一下。下午的行程：\n${CALENDAR_CONTENT}"
        ;;
    evening)
        MESSAGE="晚安！🌙 今天辛苦了！明天的行程：\n${CALENDAR_CONTENT}"
        ;;
    *)
        MESSAGE="提醒：${CALENDAR_CONTENT}"
        ;;
esac

openclaw agent --channel telegram --message "$MESSAGE" --to YOUR_USER_ID --deliver
```

設定可執行：
```bash
chmod +x ~/reminders.sh
```

### 設定多個 Cron Jobs

```bash
crontab -e
```

加入：
```cron
# 每日簡報 (早上 6:00)
0 6 * * * /home/user/daily_briefing.sh

# 早晨提醒 (早上 8:00)
0 8 * * * /home/user/reminders.sh morning

# 午間提醒 (中午 12:00)
0 12 * * * /home/user/reminders.sh noon

# 晚間提醒 (晚上 8:00)
0 20 * * * /home/user/reminders.sh evening

# 週五下午提醒 (週五 5:00 PM)
0 17 * * 5 /home/user/reminders.sh "週末愉快！🎉"
```

---

## 整合其他服務

### 1. 天氣服務

**使用 OpenWeatherMap API**：

註冊：https://openweathermap.org/api

修改 daily_briefing.sh：

```bash
# 取得天氣資訊
WEATHER_API_KEY="your-openweather-api-key"
WEATHER=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=San%20Francisco&appid=${WEATHER_API_KEY}&units=metric&lang=zh_tw")

PROMPT="今天是 ${CURRENT_DATE}。

天氣資訊：
${WEATHER}

請用繁體中文整理以上天氣資訊，並提供：
1. 今日天氣概況
2. 舊金山新聞 (2則)
3. 科技頭條 (2則)
4. 日曆事件

日曆：${CALENDAR_CONTENT}"
```

### 2. 股票資訊

**使用 Alpha Vantage API**：

註冊：https://www.alphavantage.co/

```bash
# 取得股票資訊
STOCK_API_KEY="your-alphavantage-key"
STOCKS=$(curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=AAPL&apikey=${STOCK_API_KEY}")

PROMPT="今天的 Apple (AAPL) 股價：
${STOCKS}

請用繁體中文提供：
1. 股價摘要
2. 科技新聞
3. 日曆事件"
```

### 3. Google Calendar 整合

**使用 Google Calendar API**：

```bash
# 安裝 gcalcli
pip3 install gcalcli

# 認證
gcalcli init

# 在腳本中取得今日事件
TODAY_EVENTS=$(gcalcli agenda --nostarted --tsv | head -5)

PROMPT="Google 日曆今日行程：
${TODAY_EVENTS}

請用繁體中文整理今日簡報。"
```

---

## 備份與還原

### 自動備份腳本

**創建 backup.sh**：

```bash
nano ~/backup_mimi.sh
```

內容：

```bash
#!/bin/bash
set -e

BACKUP_DIR="$HOME/mimi-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="mimi-backup-${TIMESTAMP}.tar.gz"

# 創建備份目錄
mkdir -p "$BACKUP_DIR"

# 備份檔案
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    ~/.openclaw/openclaw.json \
    ~/.openclaw/workspace/ \
    ~/daily_briefing.sh \
    ~/mimi_briefing.log

echo "備份完成: ${BACKUP_DIR}/${BACKUP_FILE}"

# 保留最近 7 天的備份
find "$BACKUP_DIR" -name "mimi-backup-*.tar.gz" -mtime +7 -delete
```

設定可執行：
```bash
chmod +x ~/backup_mimi.sh
```

### 定期自動備份

```bash
crontab -e
```

加入：
```cron
# 每天凌晨 2:00 備份
0 2 * * * /home/user/backup_mimi.sh
```

### 還原備份

```bash
# 列出備份
ls -lh ~/mimi-backups/

# 還原特定備份
tar -xzf ~/mimi-backups/mimi-backup-20260216_020000.tar.gz -C ~/

# 重啟服務
sudo systemctl restart openclaw-gateway.service
```

### 雲端備份

**同步到 Google Drive**（使用 rclone）：

```bash
# 安裝 rclone
curl https://rclone.org/install.sh | sudo bash

# 配置 Google Drive
rclone config

# 同步備份
rclone copy ~/mimi-backups/ gdrive:mimi-backups/
```

---

## 監控與告警

### 1. 健康檢查腳本

**創建 health_check.sh**：

```bash
nano ~/health_check.sh
```

內容：

```bash
#!/bin/bash
set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 檢查服務狀態
if ! systemctl is-active --quiet openclaw-gateway.service; then
    MESSAGE="⚠️ 警告：OpenClaw Gateway 服務已停止！"
    openclaw agent --channel telegram --message "$MESSAGE" --to YOUR_USER_ID --deliver
    
    # 嘗試重啟
    sudo systemctl start openclaw-gateway.service
    sleep 5
    
    if systemctl is-active --quiet openclaw-gateway.service; then
        MESSAGE="✅ OpenClaw Gateway 已成功重啟"
        openclaw agent --channel telegram --message "$MESSAGE" --to YOUR_USER_ID --deliver
    fi
fi

# 檢查硬碟空間
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    MESSAGE="⚠️ 警告：硬碟使用率已達 ${DISK_USAGE}%"
    openclaw agent --channel telegram --message "$MESSAGE" --to YOUR_USER_ID --deliver
fi

# 檢查記憶體
MEM_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3*100/$2}')
if [ "$MEM_USAGE" -gt 90 ]; then
    MESSAGE="⚠️ 警告：記憶體使用率已達 ${MEM_USAGE}%"
    openclaw agent --channel telegram --message "$MESSAGE" --to YOUR_USER_ID --deliver
fi
```

### 定期健康檢查

```bash
crontab -e
```

加入：
```cron
# 每小時檢查一次
0 * * * * /home/user/health_check.sh
```

### 2. 日誌監控

**使用 logrotate**：

```bash
sudo nano /etc/logrotate.d/mimi-bot
```

內容：

```
/home/user/mimi_briefing.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
```

---

## 效能優化

### 1. 啟用快取

編輯 openclaw.json：

```json
{
  "cache": {
    "enabled": true,
    "ttl": 3600
  }
}
```

### 2. 調整 systemd 資源限制

```bash
sudo nano /etc/systemd/system/openclaw-gateway.service
```

加入：

```ini
[Service]
CPUQuota=50%
MemoryLimit=800M
TasksMax=50
```

重新載入：
```bash
sudo systemctl daemon-reload
sudo systemctl restart openclaw-gateway.service
```

### 3. 使用更快的模型

切換到速度優化的模型：

```json
{
  "model": {
    "provider": "openrouter",
    "name": "anthropic/claude-3-haiku",
    "apiKey": "your-key"
  }
}
```

### 4. 優化搜尋結果數量

```json
{
  "tools": {
    "web": {
      "search": {
        "provider": "brave",
        "apiKey": "your-key",
        "maxResults": 3  // 減少到 3 個結果
      }
    }
  }
}
```

---

## 進階客製化範例

### 範例 1：多語言支援

在 SOUL.md 中加入：

```markdown
## 語言切換

- 預設：繁體中文
- 當用戶要求時，可切換到：
  - 英文：用戶說 "switch to English"
  - 日文：用戶說 "日本語で話して"
- 切換後保持該語言直到用戶要求切換回來
```

### 範例 2：情境感知

```markdown
## 情境感知

### 時間敏感回應
- 早上 (6-11): 使用「早安」問候
- 下午 (12-17): 使用「午安」問候
- 晚上 (18-23): 使用「晚安」問候
- 深夜 (0-5): 提醒用戶注意休息

### 週末模式
- 週六日：更輕鬆、休閒的語氣
- 工作日：更專注、效率導向
```

### 範例 3：個性化建議

```markdown
## 個性化功能

### 記住用戶偏好
- 新聞主題偏好
- 回應詳細程度
- 提醒時間偏好

### 智能建議
- 根據日曆推薦準備事項
- 根據天氣建議穿著
- 根據新聞推薦相關閱讀
```

---

## 總結

透過這些進階配置，你可以：

✅ 打造專屬的 AI 助理個性  
✅ 自訂簡報內容和時間  
✅ 整合多種外部服務  
✅ 建立完整的備份策略  
✅ 實現自動監控和告警  
✅ 優化系統效能  

**下一步**：
- 實驗不同的配置組合
- 根據使用體驗持續調整
- 分享你的配置給社群！

**需要靈感？**
- 查看 GitHub Discussions 看其他用戶的配置
- 提交你的配置範例幫助其他人

**祝你玩得開心！** 🚀
