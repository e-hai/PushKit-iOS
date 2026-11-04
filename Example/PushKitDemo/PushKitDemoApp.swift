import SwiftUI
import PushKit
import UserNotifications

@main
struct PushKitDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 绑定系统通知中心 Delegate
        PushKitManager.shared.setup()
        
        // 注册测试交互分类与动作按钮
        let replyAction = PushNotificationActionConfig(
            identifier: "ACTION_REPLY",
            title: "回复",
            options: [.foreground]
        )
        let dismissAction = PushNotificationActionConfig(
            identifier: "ACTION_DISMISS",
            title: "忽略",
            options: [.destructive]
        )
        let testCategory = NotificationCategoryConfig(
            identifier: "DEMO_CATEGORY",
            actions: [replyAction, dismissAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "%u 条新通知"
        )
        PushKitManager.shared.category.registerCategories([testCategory])
        
        // 配置前台横幅展示选项
        PushKitManager.shared.delegate.willPresentNotificationHandler = { notification in
            return [.banner, .sound, .badge, .list]
        }
        
        // 监听通知点击回调
        PushKitManager.shared.delegate.didReceiveNotificationResponseHandler = { response in
            let actionId = response.actionIdentifier
            let title = response.notification.request.content.title
            print("[PushKitDemo] 用户交互动作：\(actionId), 通知标题：\(title)")
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushKitManager.shared.apnsProvider.handleDeviceToken(deviceToken)
    }
}
