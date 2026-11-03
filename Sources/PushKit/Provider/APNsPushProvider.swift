import Foundation
#if canImport(UIKit)
import UIKit
#endif
import UserNotifications

/// APNs 原生系统推送通道实现。
public final class APNsPushProvider: NSObject, PushProvider, @unchecked Sendable {
    public let providerName: String = "APNs"
    
    private var tokenCallback: (@Sendable (String, String) -> Void)?
    private var messageListener: (@Sendable (PushMessage, String) -> Void)?
    private var cachedToken: String?
    
    public override init() {
        super.init()
    }
    
    public func register(tokenCallback: (@Sendable (String, String) -> Void)?) {
        self.tokenCallback = tokenCallback
        #if canImport(UIKit) && !os(watchOS)
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        #endif
    }
    
    public func unregister() {
        #if canImport(UIKit) && !os(watchOS)
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
        #endif
        cachedToken = nil
    }
    
    public func getToken() -> String? {
        return cachedToken
    }
    
    public func setMessageListener(_ listener: (@Sendable (PushMessage, String) -> Void)?) {
        self.messageListener = listener
    }
    
    /// 当 AppDelegate 成功获取 APNs deviceToken Data 时调用此方法进行解析和转发
    /// - Parameter deviceToken: 系统返回的二进制 DeviceToken
    public func handleDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.cachedToken = tokenString
        tokenCallback?(tokenString, providerName)
    }
    
    /// 当收到远程通知 UserInfo 字典时调用此方法处理并分发
    /// - Parameter userInfo: 推送信息字典
    public func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        let message = PushMessage(userInfo: userInfo)
        messageListener?(message, providerName)
    }
}
