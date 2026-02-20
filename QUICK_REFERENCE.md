# 📋 第一步快速參考卡

> 給已經有基本概念的用戶：快速檢查清單

---

## ✅ 第一步：Google Cloud 帳號

### 🔗 連結
**https://cloud.google.com/**

### 📝 需要準備
- Google 帳號（Gmail）
- 信用卡（僅用於驗證，不會扣款）
- 5-10 分鐘時間

### 🎯 完成後確認
- [ ] 可以登入 [Google Cloud Console](https://console.cloud.google.com/)
- [ ] 看到 $300 免費試用額度
- [ ] 已建立預設專案

---

## ✅ 第二步：取得 API Keys

### 1️⃣ Telegram Bot Token
- **網址**：https://t.me/BotFather
- **指令**：`/newbot`
- **格式**：`1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`

### 2️⃣ OpenRouter API Key
- **網址**：https://openrouter.ai/
- **位置**：Keys → Create Key
- **格式**：`sk-or-v1-...`

### 3️⃣ Brave Search API Key
- **網址**：https://brave.com/search/api/
- **等待**：審核通過（數小時）
- **格式**：`BSA...`

---

## ✅ 第三步：部署

### 方法一：使用 gcloud 指令

```bash
# 1. 建立 VM
gcloud compute instances create mimi-bot \
    --zone=us-west1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB

# 2. 連線到 VM
gcloud compute ssh mimi-bot --zone=us-west1-a

# 3. 執行部署腳本
bash <(curl -s https://raw.githubusercontent.com/shirleyiminwu-max/mimi-bot-deployment/main/setup.sh)
```

### 方法二：使用網頁介面

1. **建立 VM**：[Google Cloud Console](https://console.cloud.google.com/) → Compute Engine → VM 執行個體
2. **連線**：點擊 VM 旁的「SSH」按鈕
3. **執行部署**：複製上面的 curl 指令

---

## ⏱️ 時間預估

| 步驟 | 時間 |
|------|------|
| Google Cloud 註冊 | 5-10 分鐘 |
| 取得 Telegram Bot Token | 3 分鐘 |
| 取得 OpenRouter API Key | 3 分鐘 |
| 取得 Brave Search API Key | 5 分鐘 + 等待審核 |
| 建立和連線 VM | 5 分鐘 |
| 執行部署腳本 | 10-15 分鐘 |
| **總計** | **30-45 分鐘** |

---

## 💰 費用

| 項目 | 費用 |
|------|------|
| Google Cloud (e2-micro) | **$0/月** （免費層級） |
| OpenRouter (Gemini 2.0 Flash) | **$0** （免費模型） |
| Brave Search API | **$0** （免費層級） |
| **總計** | **$0/月** |

*超出 GCP 免費層級後約 $6/月*

---

## 🆘 遇到問題？

1. **第一次使用**：[快速入門指南](GETTING_STARTED.md)
2. **詳細步驟**：[部署指南](DEPLOYMENT_GUIDE.md)
3. **問題排除**：[故障排除](TROUBLESHOOTING.md)
4. **進階設定**：[進階配置](ADVANCED_CONFIG.md)

---

## 📱 部署後測試

```
你: 嗨 Mimi！
Mimi: 你好！😊 我是 Mimi，你的繁體中文助理！

你: 今天有什麼新聞？
Mimi: 讓我為你查詢最新的台北市士林北投區新聞和科技頭條...
```

每天早上 6:00 自動發送每日簡報！📰

---

**就是這麼簡單！** 🎉
