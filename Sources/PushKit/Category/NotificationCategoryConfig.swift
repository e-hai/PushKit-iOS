import Foundation
import UserNotifications

/// 通知动作按钮配置模型（对应系统 UNNotificationAction）。
public struct PushNotificationActionConfig: Sendable {
    /// 按钮唯一标识 ID
    public let identifier: String
    
    /// 按钮显示标题
    public let title: String
    
    /// 按钮选项（如 .authenticationRequired, .destructive, .foreground）
    public let options: UNNotificationActionOptions
    
    public init(
        identifier: String,
        title: String,
        options: UNNotificationActionOptions = []
    ) {
        self.identifier = identifier
        self.title = title
        self.options = options
    }
    
    /// 转换为原生 UNNotificationAction 对象
    public func toNativeAction() -> UNNotificationAction {
        return UNNotificationAction(
            identifier: identifier,
            title: title,
            options: options
        )
    }
}

/// iOS 交互式通知分类配置模型（对应 Android NotificationChannel 的分类与分组概念）。
public struct NotificationCategoryConfig: Sendable {
    /// 分类唯一标识符 ID (例如 "CATEGORY_CHAT", "CATEGORY_ALARM")
    public let identifier: String
    
    /// 该分类下挂载的交互操作按钮列表
    public let actions: [PushNotificationActionConfig]
    
    /// 隐藏通知详情时的意图标识符占位
    public let intentIdentifiers: [String]
    
    /// 隐藏详情时的占位格式字符串 (例如 "%u 条未读消息")
    public let hiddenPreviewsBodyPlaceholder: String?
    
    /// 分类选项（如 .customDismissAction, .allowInCarPlay）
    public let options: UNNotificationCategoryOptions
    
    public init(
        identifier: String,
        actions: [PushNotificationActionConfig] = [],
        intentIdentifiers: [String] = [],
        hiddenPreviewsBodyPlaceholder: String? = nil,
        options: UNNotificationCategoryOptions = []
    ) {
        self.identifier = identifier
        self.actions = actions
        self.intentIdentifiers = intentIdentifiers
        self.hiddenPreviewsBodyPlaceholder = hiddenPreviewsBodyPlaceholder
        self.options = options
    }
    
    /// 转换为系统原生 UNNotificationCategory 对象
    public func toNativeCategory() -> UNNotificationCategory {
        let nativeActions = actions.map { $0.toNativeAction() }
        if let placeholder = hiddenPreviewsBodyPlaceholder {
            return UNNotificationCategory(
                identifier: identifier,
                actions: nativeActions,
                intentIdentifiers: intentIdentifiers,
                hiddenPreviewsBodyPlaceholder: placeholder,
                options: options
            )
        } else {
            return UNNotificationCategory(
                identifier: identifier,
                actions: nativeActions,
                intentIdentifiers: intentIdentifiers,
                options: options
            )
        }
    }
}

/// iOS 通知分类与交互式动作管理工具类。
public final class NotificationCategoryManager: @unchecked Sendable {
    public static let shared = NotificationCategoryManager()
    
    private init() {}
    
    /// 注册一组通知分类到系统 UNUserNotificationCenter
    /// - Parameter configs: 分类配置数组
    public func registerCategories(_ configs: [NotificationCategoryConfig]) {
        let nativeCategories = Set(configs.map { $0.toNativeCategory() })
        UNUserNotificationCenter.current().setNotificationCategories(nativeCategories)
    }
    
    /// 注册单个通知分类
    /// - Parameter config: 分类配置
    public func registerCategory(_ config: NotificationCategoryConfig) async {
        let current = await UNUserNotificationCenter.current().notificationCategories()
        var updated = current.filter { $0.identifier != config.identifier }
        updated.insert(config.toNativeCategory())
        UNUserNotificationCenter.current().setNotificationCategories(updated)
    }
    
    /// 移除所有自定义通知分类
    public func clearAllCategories() {
        UNUserNotificationCenter.current().setNotificationCategories([])
    }
}
