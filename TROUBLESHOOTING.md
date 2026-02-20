# 🆘 Mimi Bot 故障排除指南

本指南幫助你診斷和解決常見問題。

## 目錄

1. [快速診斷檢查清單](#快速診斷檢查清單)
2. [常見問題](#常見問題)
3. [服務問題](#服務問題)
4. [機器人回應問題](#機器人回應問題)
5. [每日簡報問題](#每日簡報問題)
6. [配置問題](#配置問題)
7. [系統資源問題](#系統資源問題)
8. [重置與重新安裝](#重置與重新安裝)

---

## 快速診斷檢查清單

遇到問題時，依序檢查以下項目：

### ✅ 基本檢查

```bash
# 1. 檢查 VM 是否運行
gcloud compute instances list

# 2. 檢查服務狀態
sudo systemctl status openclaw-gateway.service

# 3. 檢查 Node.js
node --version

# 4. 檢查 OpenClaw CLI
openclaw --version

# 5. 檢查配置檔案
cat ~/.openclaw/openclaw.json

# 6. 檢查日誌
sudo journalctl -u openclaw-gateway.service -n 50
```

### 🔍 診斷腳本

執行系統測試：

```bash
bash ~/mimi-bot-deployment/test_mimi.sh
```

這會自動檢查 7 個關鍵項目並提供診斷報告。

---

## 常見問題

### ❌ 問題 1：無法連線到 VM

**症狀**：
```
ssh: connect to host XX.XX.XX.XX port 22: Connection refused
```

**可能原因**：
1. VM 已停止
2. 防火牆規則阻擋
3. IP 位址錯誤

**解決方法**：

**步驟 1：檢查 VM 狀態**
```bash
gcloud compute instances list
```

確認 STATUS 是 `RUNNING`。如果是 `TERMINATED`：

```bash
gcloud compute instances start mimi-bot --zone=us-west1-a
```

**步驟 2：檢查防火牆**
```bash
gcloud compute firewall-rules list
```

確保有允許 SSH (port 22) 的規則。

**步驟 3：重置 SSH 金鑰**
```bash
gcloud compute config-ssh
```

---

### ❌ 問題 2：setup.sh 執行失敗

**症狀**：
```
[ERROR] 安裝過程中出現錯誤
```

**可能原因**：
1. 網路連線問題
2. 權限不足
3. 套件來源問題

**解決方法**：

**步驟 1：檢查網路連線**
```bash
ping -c 4 google.com
```

**步驟 2：更新套件來源**
```bash
sudo apt update
sudo apt upgrade -y
```

**步驟 3：清除快取後重試**
```bash
sudo apt clean
sudo apt autoclean
# 重新執行 setup.sh
bash <(curl -s https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/setup.sh)
```

---

### ❌ 問題 3：nvm/Node.js 找不到

**症狀**：
```
command not found: node
command not found: nvm
```

**解決方法**：

**步驟 1：手動載入 nvm**
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

**步驟 2：驗證 Node.js**
```bash
node --version
# 應該顯示: v18.x.x
```

**步驟 3：設為預設版本**
```bash
nvm alias default 18
```

**步驟 4：永久修復**

編輯 `~/.bashrc`：
```bash
nano ~/.bashrc
```

在檔案末尾加入：
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

儲存後重新載入：
```bash
source ~/.bashrc
```

---

## 服務問題

### ❌ 問題 4：OpenClaw Gateway 無法啟動

**症狀**：
```
● openclaw-gateway.service - OpenClaw Gateway Service
     Active: failed (Result: exit-code)
```

**診斷步驟**：

**步驟 1：查看詳細日誌**
```bash
sudo journalctl -u openclaw-gateway.service -n 100 --no-pager
```

**步驟 2：檢查常見錯誤訊息**

**錯誤 A：配置檔案格式錯誤**
```
Error: Invalid JSON in config file
```

解決方法：
```bash
# 驗證 JSON 格式
cat ~/.openclaw/openclaw.json | python3 -m json.tool

# 如果有錯誤，重新編輯
nano ~/.openclaw/openclaw.json
```

**錯誤 B：API Key 無效**
```
Error: Invalid API key
```

解決方法：
```bash
# 檢查 API Keys 是否正確
grep "apiKey" ~/.openclaw/openclaw.json
grep "botToken" ~/.openclaw/openclaw.json

# 重新編輯配置
nano ~/.openclaw/openclaw.json
```

**錯誤 C：Port 已被佔用**
```
Error: Port 3000 is already in use
```

解決方法：
```bash
# 找出佔用 Port 的程序
sudo lsof -i :3000

# 終止該程序（替換 PID）
kill -9 <PID>

# 或更改配置使用不同 Port
nano ~/.openclaw/openclaw.json
# 修改 "port": 3001
```

**步驟 3：重新啟動服務**
```bash
sudo systemctl daemon-reload
sudo systemctl restart openclaw-gateway.service
sudo systemctl status openclaw-gateway.service
```

---

### ❌ 問題 5：服務啟動後立即停止

**症狀**：
```
Active: inactive (dead)
```

**解決方法**：

**步驟 1：檢查 Node.js 路徑**
```bash
which node
# 輸出應該類似: /home/user/.nvm/versions/node/v18.20.5/bin/node
```

**步驟 2：更新 systemd 服務檔案**
```bash
sudo nano /etc/systemd/system/openclaw-gateway.service
```

確認 `ExecStart` 路徑正確：
```ini
ExecStart=/home/YOUR_USERNAME/.nvm/versions/node/v18.20.5/bin/openclaw gateway
```

**步驟 3：重新載入並啟動**
```bash
sudo systemctl daemon-reload
sudo systemctl start openclaw-gateway.service
```

---

## 機器人回應問題

### ❌ 問題 6：Mimi 不回應訊息

**症狀**：在 Telegram 發送訊息給 Bot，但沒有回應。

**診斷步驟**：

**步驟 1：確認服務運行中**
```bash
sudo systemctl status openclaw-gateway.service
```

必須看到 `Active: active (running)`。

**步驟 2：檢查 Bot Token**
```bash
grep "botToken" ~/.openclaw/openclaw.json
```

驗證 Token 是否正確。

**步驟 3：測試 Bot Token**

使用 Telegram API 測試：
```bash
BOT_TOKEN="你的Bot Token"
curl "https://api.telegram.org/bot${BOT_TOKEN}/getMe"
```

應該返回 Bot 資訊。如果返回錯誤，Token 可能無效。

**步驟 4：檢查即時日誌**
```bash
sudo journalctl -u openclaw-gateway.service -f
```

發送一則訊息給 Bot，觀察日誌輸出。

**步驟 5：重新配對**

有時需要重新與 Bot 配對：

1. 在 Telegram 中發送 `/start` 給 Bot
2. 觀察日誌是否有反應
3. 如果沒有，重啟服務：
   ```bash
   sudo systemctl restart openclaw-gateway.service
   ```

---

### ❌ 問題 7：Mimi 用英文或簡體中文回應

**症狀**：Mimi 沒有使用繁體中文回應。

**原因**：SOUL.md 檔案配置不正確或未載入。

**解決方法**：

**步驟 1：檢查 SOUL.md**
```bash
cat ~/.openclaw/workspace/SOUL.md | head -20
```

確認前幾行包含：
```markdown
## ⚠️ **最高優先級規則** ⚠️

**你必須 100% 使用繁體中文（Traditional Chinese, zh-TW）回應所有訊息。**
```

**步驟 2：如果檔案不正確，重新下載範本**
```bash
curl -o ~/.openclaw/workspace/SOUL.md \
  https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/templates/SOUL.md
```

**步驟 3：重啟服務**
```bash
sudo systemctl restart openclaw-gateway.service
```

**步驟 4：清除對話歷史**

在 Telegram 中：
1. 發送 `/reset` 或 `/clear`（如果 Bot 支援）
2. 或刪除與 Bot 的對話後重新開始

---

### ❌ 問題 8：Mimi 回應很慢

**症狀**：需要等待 30 秒以上才收到回應。

**可能原因**：
1. API 限流
2. 網路延遲
3. AI 模型負載高

**解決方法**：

**步驟 1：檢查 OpenRouter 狀態**

訪問：https://openrouter.ai/status

**步驟 2：嘗試不同的模型**

編輯配置：
```bash
nano ~/.openclaw/openclaw.json
```

將模型改為其他選項：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "anthropic/claude-3-haiku",  // 更快的模型
    "apiKey": "你的Key"
  }
}
```

**步驟 3：檢查網路延遲**
```bash
ping -c 10 openrouter.ai
```

---

## 每日簡報問題

### ❌ 問題 9：未收到每日簡報

**症狀**：早上 6:00 沒有收到自動簡報。

**診斷步驟**：

**步驟 1：檢查 Cron Job**
```bash
crontab -l | grep daily_briefing
```

應該看到：
```
0 6 * * * /home/user/daily_briefing.sh
```

**步驟 2：檢查腳本權限**
```bash
ls -l ~/daily_briefing.sh
```

確認有執行權限（-rwxr-xr-x）。如果沒有：
```bash
chmod +x ~/daily_briefing.sh
```

**步驟 3：手動執行測試**
```bash
bash ~/daily_briefing.sh
```

檢查是否收到簡報訊息。

**步驟 4：查看簡報日誌**
```bash
tail -50 ~/mimi_briefing.log
```

尋找錯誤訊息。

**步驟 5：驗證 User ID**

確認 daily_briefing.sh 中的 User ID 正確：
```bash
grep "USER_ID" ~/daily_briefing.sh
```

應該是你的 Telegram User ID，不是 `USER_ID` 這個字串。

---

### ❌ 問題 10：簡報內容不完整

**症狀**：簡報只有部分內容，沒有新聞或日曆。

**可能原因**：
1. Brave Search API Key 無效
2. 日曆檔案不存在
3. API 限流

**解決方法**：

**步驟 1：檢查 Brave Search API Key**
```bash
grep "brave" ~/.openclaw/openclaw.json
```

**步驟 2：測試 Brave Search API**
```bash
BRAVE_KEY="你的Key"
curl -H "X-Subscription-Token: ${BRAVE_KEY}" \
  "https://api.search.brave.com/res/v1/web/search?q=test"
```

應該返回搜尋結果。

**步驟 3：檢查日曆檔案**
```bash
ls -l ~/.openclaw/workspace/CALENDAR.md
cat ~/.openclaw/workspace/CALENDAR.md
```

**步驟 4：檢查 API 用量**

前往 Brave Search Developer Portal 確認配額。

---

## 配置問題

### ❌ 問題 11：配置檔案不存在

**症狀**：
```
Error: Config file not found
```

**解決方法**：

**重新創建配置檔案**：
```bash
mkdir -p ~/.openclaw
nano ~/.openclaw/openclaw.json
```

貼上以下內容（記得替換 API Keys）：
```json
{
  "model": {
    "provider": "openrouter",
    "name": "google/gemini-2.0-flash-exp:free",
    "apiKey": "YOUR_OPENROUTER_KEY"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "YOUR_BOT_TOKEN",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 3000,
    "token": "YOUR_GATEWAY_TOKEN"
  },
  "tools": {
    "web": {
      "search": {
        "provider": "brave",
        "apiKey": "YOUR_BRAVE_KEY",
        "maxResults": 5
      }
    }
  }
}
```

設定權限：
```bash
chmod 600 ~/.openclaw/openclaw.json
```

---

### ❌ 問題 12：無法讀取日曆檔案

**症狀**：簡報中顯示「今日無特別事件」但你有設定事件。

**解決方法**：

**步驟 1：檢查檔案路徑**
```bash
echo $OPENCLAW_WORKSPACE
# 應該輸出: /home/user/.openclaw/workspace
```

**步驟 2：檢查檔案存在**
```bash
ls -l ~/.openclaw/workspace/CALENDAR.md
```

**步驟 3：檢查檔案內容**
```bash
cat ~/.openclaw/workspace/CALENDAR.md
```

**步驟 4：檢查檔案權限**
```bash
chmod 644 ~/.openclaw/workspace/CALENDAR.md
```

---

## 系統資源問題

### ❌ 問題 13：記憶體不足

**症狀**：
```
Out of memory
killed
```

**診斷**：
```bash
free -h
```

**解決方法**：

**步驟 1：創建 Swap 空間**
```bash
# 創建 2GB Swap 檔案
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久啟用
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**步驟 2：優化配置**

編輯 systemd 服務：
```bash
sudo nano /etc/systemd/system/openclaw-gateway.service
```

加入記憶體限制：
```ini
[Service]
MemoryLimit=800M
```

**步驟 3：考慮升級 VM**

如果持續出現記憶體問題，考慮升級到 e2-small：
```bash
gcloud compute instances stop mimi-bot --zone=us-west1-a
gcloud compute instances set-machine-type mimi-bot \
  --machine-type=e2-small --zone=us-west1-a
gcloud compute instances start mimi-bot --zone=us-west1-a
```

---

### ❌ 問題 14：硬碟空間不足

**症狀**：
```
No space left on device
```

**診斷**：
```bash
df -h
```

**解決方法**：

**步驟 1：清理日誌**
```bash
# 限制 systemd 日誌大小
sudo journalctl --vacuum-size=100M

# 清理 APT 快取
sudo apt clean
sudo apt autoclean
```

**步驟 2：清理 npm 快取**
```bash
npm cache clean --force
```

**步驟 3：擴充硬碟**
```bash
# 停止 VM
gcloud compute instances stop mimi-bot --zone=us-west1-a

# 擴充硬碟到 30GB
gcloud compute disks resize mimi-bot \
  --size=30GB --zone=us-west1-a

# 啟動 VM
gcloud compute instances start mimi-bot --zone=us-west1-a

# 擴展檔案系統
sudo resize2fs /dev/sda1
```

---

## 重置與重新安裝

### 🔄 完全重置（保留資料）

```bash
# 停止服務
sudo systemctl stop openclaw-gateway.service

# 備份配置
mkdir -p ~/backup
cp ~/.openclaw/openclaw.json ~/backup/
cp ~/.openclaw/workspace/*.md ~/backup/

# 重新安裝 OpenClaw
npm uninstall -g openclaw
npm install -g openclaw

# 還原配置
cp ~/backup/openclaw.json ~/.openclaw/
cp ~/backup/*.md ~/.openclaw/workspace/

# 重啟服務
sudo systemctl start openclaw-gateway.service
```

### 🗑️ 完全移除

```bash
# 停止並移除服務
sudo systemctl stop openclaw-gateway.service
sudo systemctl disable openclaw-gateway.service
sudo rm /etc/systemd/system/openclaw-gateway.service
sudo systemctl daemon-reload

# 移除 Cron Job
crontab -l | grep -v daily_briefing | crontab -

# 移除 OpenClaw
npm uninstall -g openclaw

# 移除檔案
rm -rf ~/.openclaw
rm -rf ~/mimi-bot-deployment
rm ~/daily_briefing.sh
rm ~/mimi_briefing.log

# 移除 Node.js (可選)
rm -rf ~/.nvm
```

### 🔄 重新安裝

```bash
# 清除後重新執行部署腳本
bash <(curl -s https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/setup.sh)
```

---

## 取得協助

如果上述方法都無法解決問題：

### 📝 收集診斷資訊

```bash
# 創建診斷報告
cat > ~/mimi-diagnostic.txt << 'EOF'
=== Mimi Bot 診斷報告 ===

系統資訊:
$(uname -a)

Node.js 版本:
$(node --version 2>&1)

OpenClaw 版本:
$(openclaw --version 2>&1)

服務狀態:
$(sudo systemctl status openclaw-gateway.service 2>&1)

最近日誌 (50 行):
$(sudo journalctl -u openclaw-gateway.service -n 50 --no-pager 2>&1)

配置檔案 (隱藏敏感資訊):
$(cat ~/.openclaw/openclaw.json | sed 's/"apiKey": ".*"/"apiKey": "REDACTED"/g' | sed 's/"botToken": ".*"/"botToken": "REDACTED"/g' 2>&1)

Cron Jobs:
$(crontab -l 2>&1)

硬碟使用:
$(df -h 2>&1)

記憶體使用:
$(free -h 2>&1)
EOF

cat ~/mimi-diagnostic.txt
```

### 🆘 提交 Issue

前往 GitHub 提交 Issue：
https://github.com/shirleyiminwu-max/mimi-bot-deployment/issues

包含以下資訊：
- 問題描述
- 重現步驟
- 預期行為 vs 實際行為
- 診斷報告（記得移除敏感資訊！）
- 截圖（如適用）

---

**祝你順利解決問題！** 💪

如果有任何疑問，隨時查閱其他文件或提交 GitHub Issue。
