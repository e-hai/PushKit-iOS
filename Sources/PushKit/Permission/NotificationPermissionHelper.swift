import Foundation
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

/// 通知权限状态封装枚举。
public enum NotificationPermissionStatus: Sendable {
    /// 尚未请求权限
    case notDetermined
    /// 用户明确拒绝通知权限
    case denied
    /// 用户已授予完整通知权限
    case authorized
    /// 静默推送临时试用权限 (iOS 12+)
    case provisional
    /// App Clip 临时权限 (iOS 14+)
    case ephemeral
    /// 未知状态
    case unknown
}

/// iOS 系统的 UNUserNotificationCenter 权限申请与设置辅助工具类。
public final class NotificationPermissionHelper: @unchecked Sendable {
    public static let shared = NotificationPermissionHelper()
    
    private init() {}
    
    /// 异步检查当前应用的通知授权状态
    /// - Returns: 当前统一的权限枚举
    public func getPermissionStatus() async -> NotificationPermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .unknown
        }
    }
    
    /// 请求用户授予本地与远程推送权限
    /// - Parameter options: 需要请求的授权项（默认为 [.alert, .badge, .sound]）
    /// - Returns: 是否获得授权
    @discardableResult
    public func requestPermission(
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: options)
        return granted
    }
    
    /// 判断当前是否拥有有效且可用的通知权限
    public func hasNotificationPermission() async -> Bool {
        let status = await getPermissionStatus()
        return status == .authorized || status == .provisional || status == .ephemeral
    }
    
    /// 跳转系统设置中的本应用通知设置页面
    @MainActor
    public func openNotificationSettings() {
        #if canImport(UIKit) && !os(watchOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        #endif
    }
}
