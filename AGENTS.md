# AGENTS.md - Developer & Agent Guide for PushKit (iOS)

本文档为 AI Agent 及开发者维护和扩展 `PushKit` iOS 代码库提供项目架构说明、设计规范及开发指南。

---

## 📌 项目概述

`PushKit` (iOS) 是一套纯 Swift 开发的 iOS/macOS 通知与推送封装库，目标是为 Apple 生态应用提供符合 Swift 现代范式（Swift Concurrency、DSL、Sendable 检查）的高可扩展通知与 APNs/多厂商推送机制。

---

## 📂 模块划分

采用 Swift Package Manager (SPM) 组织代码并配合 Example 演示项目：

1. **`Sources/PushKit`**（核心库代码）：
   - `PushKitManager.swift`: 单例门面，暴露统一 API。
   - `Permission/`: 权限状态检查、请求与系统设置直跳 (`NotificationPermissionHelper`)。
   - `Category/`: 交互式通知分类与快捷动作按钮 (`NotificationCategoryConfig`, `NotificationCategoryManager`)。
   - `Builder/`: 链式与闭包 DSL 构建器 (`PushNotificationBuilder`, `NotificationDSL`)。
   - `Delegate/`: 系统通知中心代理分发器 (`PushKitNotificationCenterDelegate`)。
   - `Provider/`: 统一推送协议与 APNs 原生通道实现 (`PushProvider`, `PushMessage`, `APNsPushProvider`)。

2. **`Tests/PushKitTests`**（单元测试）：
   - `PushKitTests.swift`: 测试推送消息解析、通知构建与分类配置。

3. **`Example/PushKitDemo`**（SwiftUI 演示工程）：
   - `PushKitDemo.xcodeproj`: 原生 Xcode 演示工程，直接依赖父目录本地 SPM 包。
   - `PushKitDemoApp.swift`: 应用入口，初始化 `PushKitManager` 并配置通知代理与分类。
   - `ContentView.swift`: SwiftUI 原生交互界面，展示权限请求、各类通知触发、状态实时回调。
   - `Info.plist`: 包含 `UILaunchScreen` 配置，保障全屏点对点渲染。

---

## 📐 代码规范与设计原则

1. **语言与注释**：
   - 使用 Swift 5.9+ / Swift 6 兼容语法。
   - 代码中的类、方法、协议、结构体定义**一律使用中文注释**（遵循 KDoc / SwiftDoc 格式）。
2. **兼容性与系统版本**：
   - 目标平台：`iOS 15.0+`, `macOS 12.0+`。
   - 全面支持 Swift Concurrency (`async/await`)。
   - 线程安全控制：跨并发边界访问时遵循 `Sendable` 规范并配合锁/主线程隔离 (`@MainActor`)。
3. **API 设计**：
   - 优先提供极简的 Swift DSL (`PushKitManager.shared.notify { ... }`)。
   - 架构理念对齐 `PushKit` (Android)，保持跨平台 API 概念的一致性（Channel <=> Category，DSL 命名风格一致）。
4. **扩展性**：
   - 保持 `PushProvider` 协议独立，后续新增 FCM (iOS SDK)、极光推送等第三方厂商时无需更改已有调用。

---

## 🛠️ 常用构建与验证命令

```bash
# 1. 编译 PushKit 库模块
swift build

# 2. 运行完整单元测试
swift test

# 3. 命令行编译 Demo 工程 (需指定模拟器 Destination)
xcodebuild -project Example/PushKitDemo.xcodeproj -scheme PushKitDemo -destination 'generic/platform=iOS Simulator' build
```

---

## 🏷️ 版本发布规范

1. 更新 `README.md` 与 API 文档。
2. 运行 `swift test` 确保全部测试通过。
3. 遵循语义化版本打 Git Tag（例如 `1.0.0`），推送到 GitHub 远端以供 Xcode SPM 依赖解析。

---

## ⚠️ 注意事项

- 修改公开 API 时，请同步更新 `README.md` 与测试用例。
- 增加新的源码文件时，需确保符合 `swift test` 无编译警告/错误。
- `Example/PushKitDemo.xcodeproj` 采用相对路径 `..` 引入本地 SPM 包，避免写入开发者绝对机器路径。
