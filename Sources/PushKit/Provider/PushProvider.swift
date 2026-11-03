import Foundation

/// 厂商/推送提供者通道统一协议（适配 APNs、FCM、极光等）。
public protocol PushProvider: AnyObject {
    /// 推送通道唯一标识名称（例如 "APNs", "FCM"）
    var providerName: String { get }
    
    /// 初始化或注册该推送通道
    /// - Parameter tokenCallback: Token 接收闭包
    func register(tokenCallback: (@Sendable (String, String) -> Void)?)
    
    /// 注销或解绑推送通道
    func unregister()
    
    /// 获取当前通道缓存的 Push Token（若可用）
    func getToken() -> String?
    
    /// 设置该通道的消息监听器
    /// - Parameter listener: 消息回调闭包
    func setMessageListener(_ listener: (@Sendable (PushMessage, String) -> Void)?)
}
