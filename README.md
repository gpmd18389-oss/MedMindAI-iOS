# MedMindAI iOS

iOS 原生版本，Swift + SwiftUI 开发，使用 Claude Opus 4.6 模型。

## 快速开始（无 Mac 云构建）

### 方法一：GitHub Actions 自动构建

1. **将项目推送到 GitHub**
   ```bash
   cd MedMindAI-iOS
   git init
   git add .
   git commit -m "Initial iOS project"
   gh repo create MedMindAI-iOS --private --push --source=.
   ```

2. **触发构建**
   - 推送到 main 分支会自动触发
   - 或在 GitHub → Actions → "Build iOS App" → Run workflow 手动触发

3. **下载构建产物**
   - 构建完成后，在 Actions 页面点击对应的 workflow run
   - 下载 `MedMindAI-iOS-unsigned` artifact（包含 .ipa 文件）

4. **安装到 iPhone**（需要以下任一方式）

   **方式 A：AltStore（推荐，免费）**
   - 在 Windows 上安装 [AltStore](https://altstore.io/)
   - 连接 iPhone 到电脑
   - 用 AltStore 侧载下载的 .ipa 文件
   - 每 7 天需要重新签名一次

   **方式 B：Sideloadly**
   - 下载 [Sideloadly](https://sideloadly.io/)（Windows/Mac）
   - 用 Apple ID 登录（免费 Apple ID 即可）
   - 选择 .ipa 文件安装到 iPhone
   - 同样每 7 天需要重签

   **方式 C：Apple Developer Account（$99/年）**
   - 注册 Apple Developer Program
   - 在 GitHub Actions 中配置签名证书和描述文件
   - 可通过 TestFlight 分发，无需重签

### 方法二：借用 Mac 手动构建

1. 安装 Xcode 15+ 和 XcodeGen
   ```bash
   brew install xcodegen
   ```

2. 生成 Xcode 项目并构建
   ```bash
   cd MedMindAI-iOS
   xcodegen generate
   open MedMindAI.xcodeproj
   ```

3. 在 Xcode 中：
   - 选择 iPhone 目标设备
   - Product → Build (Cmd+B)
   - 连接 iPhone → Product → Run (Cmd+R)

## 项目结构

```
MedMindAI/
├── MedMindAIApp.swift              # @main App 入口 + SwiftData
├── ContentView.swift               # TabView + Splash 动画
├── Theme/
│   └── ThemeManager.swift          # 淡粉/蓝色主题切换
├── Views/
│   ├── SplashView.swift            # 启动动画（圆环旋转）
│   ├── MainView.swift              # 主页（状态卡片 + 功能入口）
│   ├── CaptureView.swift           # 相机/相册 + OCR + AI 分析
│   ├── ResultView.swift            # AI 解析结果（分段展示）
│   ├── WrongBookView.swift         # 错题本列表 + 详情
│   └── SettingsView.swift          # 主题/API 配置/模型信息
├── Services/
│   ├── ClaudeAPIService.swift      # Claude Opus 4.6 直连
│   ├── OCRService.swift            # Apple Vision 中文 OCR
│   └── PromptProvider.swift        # 系统提示词
├── Models/
│   └── AnthropicModels.swift       # API DTO + AiAnalysis
├── Data/
│   └── WrongBookStore.swift        # SwiftData 错题实体
└── Resources/
    └── Info.plist                  # 相机/相册权限声明
```

## 功能

| 功能 | 实现方式 |
|------|---------|
| AI 模型 | Claude Opus 4.6 (`claude-opus-4-6`) |
| OCR | Apple Vision Framework（中文+英文）|
| 图片输入 | 相机拍照 / 相册选择 |
| 主题 | 少女淡粉 / 蓝色（可切换，持久化）|
| 错题本 | SwiftData 本地存储 |
| 收费/配额 | 无（完全免费无限制）|

## 环境要求

- iOS 17.0+
- Xcode 15.0+（构建时）
- Swift 5.9+
