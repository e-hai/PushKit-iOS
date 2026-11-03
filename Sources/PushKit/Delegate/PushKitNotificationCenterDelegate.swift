import Foundation
import UserNotifications

/// UNUserNotificationCenterDelegate 默认代理处理类，支持前台展示横幅与通知点击跳转分发。
public final class PushKitNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    public static let shared = PushKitNotificationCenterDelegate()
    
    /// 前台通知展示选项回调（默认前台展示 banner、list、sound、badge）
    public var willPresentNotificationHandler: (@Sendable (UNNotification) -> UNNotificationPresentationOptions)?
    
    /// 用户点击通知交互事件回调
    public var didReceiveNotificationResponseHandler: (@Sendable (UNNotificationResponse) -> Void)?
    
    public override init() {
        super.init()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if let handler = willPresentNotificationHandler {
            let options = handler(notification)
            completionHandler(options)
        } else {
            // 默认在 iOS 14+ 下前台以 Banner 形式展示通知并播放声音
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .list, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        }
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let handler = didReceiveNotificationResponseHandler {
            handler(response)
        }
        completionHandler()
    }
}
