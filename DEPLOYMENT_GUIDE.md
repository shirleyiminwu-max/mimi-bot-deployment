# 📖 Mimi Bot 詳細部署指南

本指南提供完整的逐步部署說明，包含截圖建議和詳細解釋。

## 目錄

1. [部署前準備](#部署前準備)
2. [取得 API Keys](#取得-api-keys)
3. [建立 Google Cloud VM](#建立-google-cloud-vm)
4. [執行一鍵部署腳本](#執行一鍵部署腳本)
5. [驗證部署](#驗證部署)
6. [測試 Mimi Bot](#測試-mimi-bot)
7. [日常管理](#日常管理)

---

## 部署前準備

### ✅ 必要條件檢查清單

在開始之前，請確保你有：

- [ ] **Google Cloud 帳號**
  - 新用戶有 $300 免費額度（90 天）
  - 需要信用卡驗證（但不會自動扣款）
  - 註冊網址：https://cloud.google.com/

- [ ] **Telegram 帳號**
  - 已安裝 Telegram 應用程式
  - 能夠與 Bot 互動

- [ ] **基本 Linux 指令知識**（可選）
  - 了解基本的終端機操作
  - 能夠編輯文字檔案

### 💰 成本預估

使用 **e2-micro** 機器類型：
- 在 GCP 免費層級內：**$0/月**
- 超出免費額度後：約 **$6/月**
- OpenRouter (Gemini 2.0 Flash)：**免費**
- Brave Search API：**免費層級**

**總結**：大部分用戶完全免費！

---

## 取得 API Keys

### 1. Telegram Bot Token

**步驟**：

1. 在 Telegram 中搜尋 `@BotFather`
2. 發送指令：`/newbot`
3. 設定 Bot 名稱：例如 `Mimi Bot`
4. 設定 Bot 使用者名稱：例如 `WumiBotbot` (必須以 'bot' 結尾)
5. BotFather 會回傳你的 Bot Token

**範例**：
```
Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

**⚠️ 注意**：
- 這個 Token 很重要，不要分享給他人！
- 複製並保存這個 Token，稍後會用到

### 2. OpenRouter API Key

**步驟**：

1. 前往 https://openrouter.ai/
2. 點擊右上角 **Sign In** 或 **Get Started**
3. 使用 Google 或 GitHub 帳號登入
4. 進入 **Keys** 頁面
5. 點擊 **Create Key** 創建新的 API Key
6. 複製並保存這個 Key

**範例**：
```
sk-or-v1-1234567890abcdefghijklmnopqrstuvwxyz
```

**💡 提示**：
- OpenRouter 提供免費的 Gemini 2.0 Flash 模型
- 不需要信用卡即可使用免費模型

### 3. Brave Search API Key

**步驟**：

1. 前往 https://brave.com/search/api/
2. 點擊 **Get Started**
3. 填寫註冊表單（email、用途等）
4. 等待審核通過（通常幾小時內）
5. 登入後進入 **Developer Portal**
6. 在 **API Keys** 頁面創建新的 Key
7. 複製並保存這個 Key

**範例**：
```
BSA1234567890abcdefghijklmnopqrstuvwxyz
```

**💡 提示**：
- 免費層級：每月 2,000 次搜尋請求
- 對於個人使用已經足夠

### 4. Telegram User ID

**如何取得你的 Telegram User ID**：

**方法 1：使用 Bot**
1. 在 Telegram 搜尋 `@userinfobot`
2. 發送任何訊息給它
3. 它會回傳你的 User ID

**方法 2：使用網頁版**
1. 前往 https://web.telegram.org/
2. 登入後，查看網址列
3. 你的 User ID 在網址中：`https://web.telegram.org/k/#1234567890`

**範例**：
```
Your User ID: 8542522819
```

---

## 建立 Google Cloud VM

### 方法 A：使用 gcloud 指令（推薦）

**1. 安裝 Google Cloud SDK**（如果尚未安裝）

訪問：https://cloud.google.com/sdk/docs/install

**2. 初始化並登入**

```bash
gcloud init
gcloud auth login
```

**3. 建立 VM 實例**

```bash
gcloud compute instances create mimi-bot \
    --zone=us-west1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard
```

**參數說明**：
- `--zone=us-west1-a`：美國西岸區域（或選擇離台北較近的 asia-east1）
- `--machine-type=e2-micro`：免費層級的機器類型
- `--image-family=ubuntu-2204-lts`：Ubuntu 22.04 LTS
- `--boot-disk-size=20GB`：20GB 儲存空間

**預期輸出**：
```
Created [https://www.googleapis.com/compute/v1/projects/...].
NAME      ZONE        MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
mimi-bot  us-west1-a  e2-micro                   10.138.0.2   35.199.xxx.xxx RUNNING
```

### 方法 B：使用網頁介面

**1. 前往 Google Cloud Console**

https://console.cloud.google.com/

**2. 建立新專案（如果需要）**

- 左上角選單 → **IAM & Admin** → **Create a Project**
- 專案名稱：`mimi-bot-project`

**3. 前往 Compute Engine**

- 左側選單 → **Compute Engine** → **VM instances**
- 點擊 **CREATE INSTANCE**

**4. 配置 VM**

| 設定項目 | 值 |
|---------|-----|
| **Name** | `mimi-bot` |
| **Region** | `us-west1` (Oregon) |
| **Zone** | `us-west1-a` |
| **Machine family** | General-purpose |
| **Series** | E2 |
| **Machine type** | e2-micro (0.25-2 vCPU, 1 GB memory) |
| **Boot disk** | Ubuntu 22.04 LTS |
| **Boot disk type** | Standard persistent disk |
| **Size** | 20 GB |

**5. 點擊 CREATE**

等待 1-2 分鐘，VM 會開始運行。

---

## 執行一鍵部署腳本

### 步驟 1：連線到 VM

**使用 gcloud（推薦）**：

```bash
gcloud compute ssh mimi-bot --zone=us-west1-a
```

**使用網頁 SSH**：

1. 在 VM instances 頁面
2. 找到 `mimi-bot`
3. 點擊 **SSH** 按鈕
4. 瀏覽器會開啟終端機視窗

### 步驟 2：執行部署腳本

**一鍵執行**：

```bash
bash <(curl -s https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/setup.sh)
```

### 步驟 3：輸入配置資訊

腳本會依序詢問以下資訊：

**1. Telegram Bot Token**
```
Telegram Bot Token: 1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

**2. OpenRouter API Key**
```
OpenRouter API Key: sk-or-v1-1234567890abcdefghijklmnopqrstuvwxyz
```

**3. Brave Search API Key**
```
Brave Search API Key: BSA1234567890abcdefghijklmnopqrstuvwxyz
```

**4. Telegram User ID**
```
Telegram User ID [預設: 8542522819]: 你的UserID
```

### 步驟 4：確認配置

腳本會顯示配置摘要：

```
配置摘要：
  Bot Token: 1234567890...
  OpenRouter Key: sk-or-v1-...
  Brave Search Key: BSA123456...
  User ID: 8542522819
  Gateway Token: a1b2c3d4e5... (自動生成)

確認以上資訊正確？按 Enter 繼續...
```

### 步驟 5：等待安裝完成

腳本會自動執行 12 個步驟：

```
🔄 步驟 1/12: 更新系統套件
✅ 系統更新完成

🛠️  步驟 2/12: 安裝基本工具
✅ 基本工具安裝完成

📦 步驟 3/12: 安裝 Node.js v18
✅ Node.js 安裝完成 (版本: v18.20.5)

... (持續 10-15 分鐘)

🎉 步驟 12/12: 設定 Cron Job
✅ Cron Job 設定完成（每天 6:00 AM）
```

### 步驟 6：啟動服務

最後會詢問是否立即啟動服務：

```
是否立即啟動 OpenClaw Gateway 服務？(y/n) [y]:
```

輸入 `y` 並按 Enter，服務會自動啟動。

**成功訊息**：
```
✅ OpenClaw Gateway 已成功啟動！

🎉 Mimi Bot 已準備就緒！
現在可以在 Telegram 上與 @WumiBotbot 對話了！
```

---

## 驗證部署

### 1. 執行系統測試腳本

```bash
bash ~/mimi-bot-deployment/test_mimi.sh
```

或如果你已經 clone 倉庫：

```bash
bash test_mimi.sh
```

**預期輸出**：
```
╔══════════════════════════════════════════════════════════╗
║          🧪 Mimi Bot 系統測試腳本 🧪                      ║
╚══════════════════════════════════════════════════════════╝

[測試 1] 檢查 Node.js 安裝
  ✅ PASS: Node.js v18 已正確安裝

[測試 2] 檢查 OpenClaw CLI
  ✅ PASS: OpenClaw CLI 已安裝

... (7 項測試)

總測試數: 7
通過: 7
失敗: 0

╔══════════════════════════════════════════════════════════╗
║          ✅ 所有測試通過！系統運作正常！✅                ║
╚══════════════════════════════════════════════════════════╝
```

### 2. 檢查服務狀態

```bash
sudo systemctl status openclaw-gateway.service
```

**預期輸出**：
```
● openclaw-gateway.service - OpenClaw Gateway Service for Mimi Bot
     Loaded: loaded (/etc/systemd/system/openclaw-gateway.service; enabled)
     Active: active (running) since ...
```

如果看到 `Active: active (running)`，表示服務正常運行！

### 3. 查看日誌

```bash
sudo journalctl -u openclaw-gateway.service -n 50
```

檢查是否有錯誤訊息。

---

## 測試 Mimi Bot

### 1. 在 Telegram 上找到你的 Bot

1. 打開 Telegram
2. 搜尋你的 Bot 使用者名稱（例如 `@WumiBotbot`）
3. 點擊開始對話

### 2. 發送測試訊息

**測試 1：基本對話**

```
你: 你好
Mimi: 你好！😊 我是 Mimi，你的繁體中文助理！有什麼我可以幫你的嗎？
```

**測試 2：確認語言**

```
你: Hello
Mimi: 你好！😊 我是 Mimi，你的繁體中文助理！有什麼我可以幫你的嗎？
```

**測試 3：新聞搜尋**

```
你: 今天有什麼科技新聞？
Mimi: 讓我為你查詢最新的科技頭條...

💻 **科技頭條**
1. [新聞標題 1]
2. [新聞標題 2]
...
```

**✅ 驗證重點**：
- Mimi 使用繁體中文回應（不是簡體中文或英文）
- 回應速度合理（幾秒內）
- 能夠搜尋網路資訊

### 3. 測試每日簡報

**手動執行簡報腳本**：

```bash
bash ~/daily_briefing.sh
```

檢查 Telegram 是否收到簡報訊息。

**查看簡報日誌**：

```bash
tail -f ~/mimi_briefing.log
```

---

## 日常管理

### 常用指令

**服務管理**：

```bash
# 查看服務狀態
sudo systemctl status openclaw-gateway.service

# 啟動服務
sudo systemctl start openclaw-gateway.service

# 停止服務
sudo systemctl stop openclaw-gateway.service

# 重啟服務
sudo systemctl restart openclaw-gateway.service

# 查看即時日誌
sudo journalctl -u openclaw-gateway.service -f
```

**檔案編輯**：

```bash
# 編輯 Mimi 個性
nano ~/.openclaw/workspace/SOUL.md

# 編輯日曆
nano ~/.openclaw/workspace/CALENDAR.md

# 編輯配置
nano ~/.openclaw/openclaw.json
```

**Cron Job 管理**：

```bash
# 查看 Cron 任務
crontab -l

# 編輯 Cron 任務
crontab -e
```

### 更新日曆事件

**範例**：新增生日提醒

```bash
nano ~/.openclaw/workspace/CALENDAR.md
```

新增內容：

```markdown
### 3月25日（星期三）
- 🎂 **媽媽生日**
  - 記得打電話祝賀
  - 準備禮物
```

儲存後，明天的簡報就會包含這個提醒！

### 監控日誌

**查看簡報執行記錄**：

```bash
tail -50 ~/mimi_briefing.log
```

**查看系統日誌**：

```bash
sudo journalctl -u openclaw-gateway.service --since "1 hour ago"
```

---

## 常見問題

### Q: 如何更改簡報時間？

**A:** 編輯 crontab：

```bash
crontab -e
```

找到這一行：
```
0 6 * * * /home/your_user/daily_briefing.sh
```

修改為想要的時間（例如改成早上 8:00）：
```
0 8 * * * /home/your_user/daily_briefing.sh
```

儲存並退出。

### Q: 如何備份配置？

**A:** 執行以下指令：

```bash
# 建立備份目錄
mkdir -p ~/mimi-backup

# 備份配置檔案
cp ~/.openclaw/openclaw.json ~/mimi-backup/
cp ~/.openclaw/workspace/*.md ~/mimi-backup/
cp ~/daily_briefing.sh ~/mimi-backup/

# 壓縮備份
tar -czf ~/mimi-backup-$(date +%Y%m%d).tar.gz ~/mimi-backup/
```

### Q: 如何還原？

**A:** 解壓縮並複製回原位置：

```bash
tar -xzf ~/mimi-backup-20260216.tar.gz
cp ~/mimi-backup/openclaw.json ~/.openclaw/
cp ~/mimi-backup/*.md ~/.openclaw/workspace/
```

---

## 下一步

✅ **部署成功！** 恭喜你完成 Mimi Bot 的部署！

**建議操作**：

1. 📖 閱讀 [進階配置指南](ADVANCED_CONFIG.md) 學習更多客製化選項
2. 🆘 收藏 [故障排除指南](TROUBLESHOOTING.md) 以備不時之需
3. 🌟 在 GitHub 給專案一個 Star！
4. 📅 定期更新日曆檔案，讓 Mimi 提醒你重要事件

---

**需要協助？**
- 📧 GitHub Issues: https://github.com/shirleyiminwu-max/mimi-bot-deployment/issues
- 📖 查看其他文件：README.md, TROUBLESHOOTING.md, ADVANCED_CONFIG.md

**祝你使用愉快！** 🎉
