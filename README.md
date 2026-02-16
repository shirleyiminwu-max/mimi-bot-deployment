# 🤖 Mimi Bot - 一鍵部署包

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Google Cloud](https://img.shields.io/badge/Platform-Google%20Cloud-4285F4)](https://cloud.google.com/)
[![OS: Ubuntu 22.04](https://img.shields.io/badge/OS-Ubuntu%2022.04-E95420)](https://ubuntu.com/)

一個專為 Google Cloud Platform 設計的 Telegram 機器人部署方案，使用 OpenClaw 框架。

## ✨ 特色功能

- 🌏 **繁體中文優先**：Mimi 堅持使用繁體中文溝通
- 📰 **每日簡報**：自動提供舊金山當地新聞和科技頭條
- 📅 **智能提醒**：日曆事件追蹤和提醒
- 🚀 **一鍵部署**：完全自動化安裝流程（10-15 分鐘）
- 💰 **成本低廉**：使用 GCP 免費額度，基本免費
- 🔒 **安全可靠**：自動生成加密 Token，配置檔案權限保護

## 🎯 快速開始

### 前置需求

- ✅ Google Cloud 帳號（新用戶有 $300 免費額度）
- ✅ Telegram Bot Token（從 [@BotFather](https://t.me/BotFather) 取得）
- ✅ [OpenRouter API Key](https://openrouter.ai/)
- ✅ [Brave Search API Key](https://brave.com/search/api/)

### 三步驟完成部署

#### 1️⃣ 建立 Google Cloud VM

**使用 gcloud 指令**：
```bash
gcloud compute instances create mimi-bot \
    --zone=us-west1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB
```

**或使用網頁介面**：
- 前往 [Google Cloud Console](https://console.cloud.google.com/)
- Compute Engine → VM 執行個體 → 建立執行個體
- 名稱：`mimi-bot`
- 機器類型：`e2-micro`
- 作業系統：`Ubuntu 22.04 LTS`

#### 2️⃣ 連線到 VM

```bash
gcloud compute ssh mimi-bot --zone=us-west1-a
```

#### 3️⃣ 執行一鍵部署

```bash
bash <(curl -s https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/setup.sh)
```

**就這麼簡單！** 🎉

輸入你的 API keys，等待 10-15 分鐘，Mimi 就部署完成了！

## 📸 部署截圖示範

```
╔══════════════════════════════════════════════════════════╗
║        🤖 Mimi Bot 一鍵部署腳本 🤖                        ║
╚══════════════════════════════════════════════════════════╝

[INFO] 步驟 1/10: 更新系統套件...
[SUCCESS] 系統更新完成
[INFO] 步驟 2/10: 安裝基本工具...
[SUCCESS] 基本工具安裝完成
...
╔══════════════════════════════════════════════════════════╗
║              🎉 安裝完成！🎉                              ║
╚══════════════════════════════════════════════════════════╝
```

## 📚 完整文件

- 📖 [詳細部署指南](DEPLOYMENT_GUIDE.md) - 逐步說明和截圖
- 🆘 [故障排除指南](TROUBLESHOOTING.md) - 常見問題解決方案
- 🔧 [進階配置指南](ADVANCED_CONFIG.md) - 自訂功能和優化

## 🛠️ 包含的檔案

| 檔案 | 說明 |
|------|------|
| `setup.sh` | 主安裝腳本（一鍵部署） |
| `test_mimi.sh` | 系統測試腳本 |
| `templates/SOUL.md` | Mimi 個性檔案範本 |
| `templates/IDENTITY.md` | Mimi 身份檔案範本 |
| `templates/CALENDAR.md` | 日曆檔案範本 |
| `templates/daily_briefing.sh` | 每日簡報腳本範本 |

## 🎬 使用示範

部署完成後，在 Telegram 上與 Mimi 對話：

```
你: 嗨 Mimi！
Mimi: 你好！😊 我是 Mimi，你的繁體中文助理！有什麼我可以幫你的嗎？

你: 今天有什麼新聞？
Mimi: 讓我為你查詢最新的舊金山新聞和科技頭條...

[Mimi 會提供繁體中文的新聞簡報]
```

每天早上 6:00，Mimi 會自動發送每日簡報！📰

## 💰 成本估算

| 項目 | 免費額度 | 超出後費用 |
|------|---------|-----------|
| **GCP VM** (e2-micro) | ✅ 每月免費 | ~$6/月 |
| **OpenRouter** (Gemini 2.0 Flash) | ✅ 免費模型 | $0 |
| **Brave Search API** | ✅ 免費層級 | $0 |
| **儲存** (20GB) | ✅ 30GB 免費 | $0 |
| **總計** | **$0/月** | ~$6/月 |

💡 **結論**：在 GCP 免費額度內，基本**完全免費**！

## 🔧 常用管理指令

```bash
# 查看服務狀態
sudo systemctl status openclaw-gateway.service

# 查看即時日誌
sudo journalctl -u openclaw-gateway.service -f

# 測試每日簡報
bash ~/daily_briefing.sh

# 編輯 Mimi 個性
nano ~/.openclaw/workspace/SOUL.md

# 編輯日曆
nano ~/.openclaw/workspace/CALENDAR.md

# 重啟服務
sudo systemctl restart openclaw-gateway.service
```

## ✅ 部署檢查清單

完成部署後，確認以下項目：

- [ ] VM 實例正常運行
- [ ] 可以透過 SSH 連線
- [ ] Gateway 服務運行中：`systemctl status openclaw-gateway.service`
- [ ] 在 Telegram 上可以與 Mimi 對話
- [ ] 每日簡報腳本可執行：`bash ~/daily_briefing.sh`
- [ ] Cron Job 已設定：`crontab -l`
- [ ] Mimi 使用繁體中文回應 ✅

## 🆘 需要協助？

- 📖 查看 [故障排除指南](TROUBLESHOOTING.md)
- 🐛 [開啟 GitHub Issue](https://github.com/shirleyiminwu-max/mimi-bot-deployment/issues)
- 📧 聯絡作者

## 🌟 專案亮點

- ⚡ **快速部署**：15 分鐘內完成
- 🔄 **全自動化**：無需手動配置
- 📱 **立即可用**：部署完馬上能用
- 🛡️ **安全設計**：加密 Token，權限控制
- 📊 **完整監控**：日誌、狀態檢查
- 🔧 **易於維護**：清晰的文件和工具

## 🙏 致謝

- [OpenClaw](https://openclaw.ai/) - AI Agent 框架
- [Google Cloud Platform](https://cloud.google.com/) - 雲端運算平台
- [Telegram](https://telegram.org/) - 即時通訊平台

## 📄 授權

MIT License - 詳見 [LICENSE](LICENSE) 檔案

---

**建立日期**：2026-02-16  
**作者**：Shirley Wu  
**版本**：1.0.0

💡 **提示**：如果這個專案對你有幫助，請給個 ⭐ Star！
