# PushKit - iOS (Swift) 通知与推送封装库

`PushKit` (iOS) 是一套轻量、现代、优雅的 iOS 通知与推送封装库，全面基于 Swift 5.9+ 并适配 iOS 14.0+ 与 macOS 11.0+。通过极简的 **Swift DSL**、对齐 Android `NotificationChannel` 哲学的 **交互式通知分类 (`NotificationCategoryManager`)**、**权限异步辅助 (`NotificationPermissionHelper`)**、**前台 Banner / 点击代理分发 (`PushKitNotificationCenterDelegate`)** 以及 **多推送通道抽象 (`PushProvider` / `APNsPushProvider`)**，大幅降低 iOS 通知开发门槛。

---

## 🌟 核心特性

- 🚀 **Swift DSL 链式构建**：通过 `PushKitManager.shared.notify { ... }` 极简闭包快速装配富文本、声音、附件与触发器并发送通知。
- 📢 **交互式通知分类 (`NotificationCategoryManager`)**：快捷注册 `NotificationCategoryConfig` 与动作按钮，对齐 Android 8.0+ 渠道与分类规范。
- 🛡️ **异步权限管理 (`NotificationPermissionHelper`)**：全面基于 Swift Concurrency (`async/await`) 查询与请求通知权限，提供系统设置直跳方法。
- 🔔 **统一 Delegate 托管 (`PushKitNotificationCenterDelegate`)**：开箱即用支持前台通知横幅展示（iOS 14+ `.banner, .list, .sound, .badge`）与点击跳转回调。
- 🔌 **推送通道抽象 (`PushProvider`)**：原生内置 `APNsPushProvider`，轻松扩展 FCM、极光等第三方推送 SDK。
- 📦 **Swift Package Manager (SPM) 原生支持**：极简集成，支持语义化版本发布。

---

## 📐 代码架构图解

```mermaid
flowchart TB
    App["应用业务层 (AppDelegate / SwiftUI App)"]
    
    subgraph PushKit ["PushKit iOS 核心库 (SPM)"]
        Facade["PushKitManager.shared<br/>(单例门面类)"]
        
        subgraph CategoryModule ["分类与动作 (Category)"]
            CategoryMgr["NotificationCategoryManager"]
            CategoryConfig["NotificationCategoryConfig<br/>PushNotificationActionConfig"]
        end
        
        subgraph PermissionModule ["权限辅助 (Permission)"]
            PermHelper["NotificationPermissionHelper<br/>(async/await / Status)"]
        end
        
        subgraph BuilderModule ["通知 DSL & 构建器 (Builder)"]
            DSL["NotificationDSL<br/>(notify 闭包扩展)"]
            Builder["PushNotificationBuilder"]
            Trigger["NotificationTriggerType<br/>(immediate / timeInterval / calendar)"]
            Attachment["NotificationAttachmentConfig"]
        end
        
        subgraph DelegateModule ["系统中心代理 (Delegate)"]
            Delegate["PushKitNotificationCenterDelegate<br/>(willPresent / didReceive)"]
        end
        
        subgraph ProviderModule ["多厂商推送抽象 (Provider)"]
            PushProviderInterface["<<Protocol>><br/>PushProvider"]
            PushMessage["PushMessage<br/>(统一解析 APNs / 厂商负载)"]
            APNs["APNsPushProvider<br/>(handleDeviceToken / handleRemoteNotification)"]
        end
    end
    
    UNCenter["iOS 系统通知中心<br/>(UNUserNotificationCenter)"]
    APNsServer["Apple Push Notification service<br/>(APNs 云端)"]

    %% 交互链路
    App -->|1. 初始化与配置| Facade
    App -->|2. 构建发送本地通知| DSL
    
    Facade --> CategoryMgr
    Facade --> PermHelper
    Facade --> Delegate
    Facade --> PushProviderInterface
    
    DSL --> Builder
    Builder --> Trigger
    Builder --> Attachment
    Builder -->|3. 投递通知请求| UNCenter
    
    CategoryMgr --> CategoryConfig
    CategoryConfig -->|注册分类与按钮| UNCenter
    
    APNs -.->|实现| PushProviderInterface
    APNsServer -->|4. 推送下发| APNs
    APNs --> PushMessage
```

---

## 🛠️ 项目结构

```
PushKit (iOS Branch)
├── Package.swift                             # SPM 依赖与模块定义
├── Sources/PushKit/
│   ├── PushKitManager.swift                  # 核心门面单例类
│   ├── Permission/
│   │   └── NotificationPermissionHelper.swift # async/await 权限请求与设置跳转
│   ├── Category/
│   │   └── NotificationCategoryConfig.swift   # 通知分类与交互按钮管理器
│   ├── Builder/
│   │   ├── PushNotificationBuilder.swift     # 链式构建器与触发器封装
│   │   └── NotificationDSL.swift             # 闭包 DSL 快捷语法
│   ├── Delegate/
│   │   └── PushKitNotificationCenterDelegate.swift # 前台展示与交互回调 Delegate
│   └── Provider/
│       ├── PushMessage.swift                 # 统一推送消息数据模型
│       ├── PushProvider.swift                # 厂商推送通道协议
│       └── APNsPushProvider.swift            # APNs 原生推送通道实现
└── Tests/PushKitTests/
    └── PushKitTests.swift                    # 单元测试套件
```

---

## 🚀 快速上手

### 1. 依赖配置 (SPM)

在 Xcode 项目中选择 **File > Add Package Dependencies...**，输入仓库地址并选定 `ios` 分支或对应发布 Tag：

```swift
dependencies: [
    .package(url: "https://github.com/e-hai/PushKit.git", branch: "ios")
]
```

---

### 2. 初始化与前台通知设置

在 `AppDelegate` 或 `@main App` 的 `init()` 中进行设置：

```swift
import UIKit
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 绑定系统通知中心 Delegate
        PushKitManager.shared.setup()
        
        // 自定义前台通知横幅展示（可选）
        PushKitManager.shared.delegate.willPresentNotificationHandler = { notification in
            return [.banner, .sound, .badge]
        }
        
        // 监听用户点击通知行为（可选）
        PushKitManager.shared.delegate.didReceiveNotificationResponseHandler = { response in
            let userInfo = response.notification.request.content.userInfo
            print("用户点击了通知：\(userInfo)")
        }
        
        return true
    }
}
```

---

### 3. 请求通知权限

```swift
// 异步请求通知权限
Task {
    do {
        let granted = try await PushKitManager.shared.requestPermission(options: [.alert, .badge, .sound])
        print("通知授权状态：\(granted)")
    } catch {
        print("权限请求失败：\(error)")
    }
}

// 跳转系统设置
PushKitManager.shared.openNotificationSettings()
```

---

### 4. 发送通知 (使用 Swift DSL)

#### 发送普通通知
```swift
Task {
    try? await PushKitManager.shared.notify(id: "msg_1001") { builder in
        builder.title = "新消息提醒"
        builder.subtitle = "系统公告"
        builder.body = "您收到一条来自 PushKit (iOS) 的通知消息。"
        builder.badge = 1
        builder.userInfo = ["type": "chat", "chat_id": 12345]
    }
}
```

#### 发送倒计时通知 (带触发器)
```swift
Task {
    try? await PushKitManager.shared.notify(id: "reminder_1002") { builder in
        builder.title = "倒计时提醒"
        builder.body = "5 秒钟前设置的提醒已到达！"
        builder.triggerType = .timeInterval(seconds: 5, repeats: false)
    }
}
```

#### 发送富媒体图片通知
```swift
if let imageURL = Bundle.main.url(forResource: "banner", withExtension: "jpg") {
    Task {
        try? await PushKitManager.shared.notify(id: "image_1003") { builder in
            builder.title = "图文并茂的通知"
            builder.body = "长按或下拉通知栏展开查看图片。"
            builder.addAttachment(fileURL: imageURL)
        }
    }
}
```

---

### 5. 注册 APNs 与接收远程推送

```swift
// 1. 在 AppDelegate 中接收 DeviceToken 并转发给 PushKit
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushKitManager.shared.apnsProvider.handleDeviceToken(deviceToken)
}

// 2. 接收 APNs 远程推送消息
PushKitManager.shared.apnsProvider.setMessageListener { message, providerName in
    print("收到来自 [\(providerName)] 的远程推送：title=\(message.title ?? ""), body=\(message.body ?? "")")
    print("自定义负载：\(message.payload)")
}

// 3. 注册 APNs
PushKitManager.shared.apnsProvider.register { token, provider in
    print("成功获取 \(provider) DeviceToken: \(token)")
}
```

---

## ⚙️ 编译与测试

```bash
# 编译库模块
swift build

# 运行单元测试
swift test
```

---

## 📄 License

本项目采用 MIT 许可证，详情参见 LICENSE 文件。
