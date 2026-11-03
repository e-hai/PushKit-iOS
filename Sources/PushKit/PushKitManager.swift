import Foundation
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

/// PushKit iOS 核心入口单例门面，统筹权限管理、通知分类、构建发送与多通道推送。
public final class PushKitManager: @unchecked Sendable {
    public static let shared = PushKitManager()
    
    /// 权限与系统设置辅助管理器
    public let permission = NotificationPermissionHelper.shared
    
    /// 交互分类与动作按钮管理器
    public let category = NotificationCategoryManager.shared
    
    /// 系统通知中心默认 Delegate
    public let delegate = PushKitNotificationCenterDelegate.shared
    
    /// APNs 原生通道
    public let apnsProvider = APNsPushProvider()
    
    /// 已注册的多厂商通道映射表
    private var providers: [String: PushProvider] = [:]
    private let lock = NSLock()
    
    private init() {
        registerProvider(apnsProvider)
    }
    
    /// 初始化 PushKit 并绑定 UNUserNotificationCenterDelegate
    public func setup() {
        UNUserNotificationCenter.current().delegate = delegate
    }
    
    // MARK: - 权限快捷 API
    
    /// 检查是否有通知权限
    public func hasNotificationPermission() async -> Bool {
        return await permission.hasNotificationPermission()
    }
    
    /// 请求通知权限
    @discardableResult
    public func requestPermission(
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) async throws -> Bool {
        return try await permission.requestPermission(options: options)
    }
    
    /// 打开系统应用设置
    @MainActor
    public func openNotificationSettings() {
        permission.openNotificationSettings()
    }
    
    // MARK: - 发送与管理通知
    
    /// 投递原生通知请求
    /// - Parameter request: UNNotificationRequest
    public func post(_ request: UNNotificationRequest) async throws {
        try await UNUserNotificationCenter.current().add(request)
    }
    
    /// 根据 ID 移除指定已交付或待触发的通知
    /// - Parameter identifiers: 通知 ID 数组
    public func cancel(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    /// 清除所有待触发与已显示的通知
    public func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /// 设置桌面应用角标数字
    @MainActor
    public func setBadgeCount(_ count: Int) {
        #if canImport(UIKit) && !os(watchOS)
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
        #endif
    }
    
    // MARK: - 推送通道管理
    
    /// 注册自定义推送通道（如 FCM、第三方厂商等）
    public func registerProvider(_ provider: PushProvider) {
        lock.lock()
        defer { lock.unlock() }
        providers[provider.providerName] = provider
    }
    
    /// 获取指定名称的推送通道
    public func getProvider(_ name: String) -> PushProvider? {
        lock.lock()
        defer { lock.unlock() }
        return providers[name]
    }
}
