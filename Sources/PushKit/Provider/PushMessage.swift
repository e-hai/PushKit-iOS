import Foundation

/// 通用推送消息数据模型，统一 APNs、FCM 及自定义推送负载。
public struct PushMessage: @unchecked Sendable, Equatable {
    /// 消息唯一标识 ID
    public let id: String?
    
    /// 消息标题
    public let title: String?
    
    /// 消息副标题
    public let subtitle: String?
    
    /// 消息正文内容
    public let body: String?
    
    /// 应用角标数字
    public let badge: NSNumber?
    
    /// 提示音名称（如 "default" 或自定义音频文件名）
    public let sound: String?
    
    /// 业务自定义 Payload 键值对字典
    public let payload: [String: Any]
    
    /// 原始推送 UserInfo 字典
    public let userInfo: [AnyHashable: Any]
    
    /// 初始化通用推送消息
    /// - Parameters:
    ///   - id: 消息 ID
    ///   - title: 标题
    ///   - subtitle: 副标题
    ///   - body: 正文
    ///   - badge: 角标数
    ///   - sound: 声音
    ///   - payload: 自定义负载
    ///   - userInfo: 原始 UserInfo 字典
    public init(
        id: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        body: String? = nil,
        badge: NSNumber? = nil,
        sound: String? = nil,
        payload: [String: Any] = [:],
        userInfo: [AnyHashable: Any] = [:]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.badge = badge
        self.sound = sound
        self.payload = payload
        self.userInfo = userInfo
    }
    
    /// 从 APNs 原始 userInfo 字典解析生成统一 PushMessage
    /// - Parameter userInfo: APNs 推送字典
    public init(userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.id = userInfo["gcm.message_id"] as? String ?? userInfo["id"] as? String
        
        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                self.title = alert["title"] as? String
                self.subtitle = alert["subtitle"] as? String
                self.body = alert["body"] as? String
            } else if let alertString = aps["alert"] as? String {
                self.title = nil
                self.subtitle = nil
                self.body = alertString
            } else {
                self.title = nil
                self.subtitle = nil
                self.body = nil
            }
            
            self.badge = aps["badge"] as? NSNumber
            if let soundDict = aps["sound"] as? [String: Any] {
                self.sound = soundDict["name"] as? String
            } else {
                self.sound = aps["sound"] as? String
            }
        } else {
            self.title = userInfo["title"] as? String
            self.subtitle = userInfo["subtitle"] as? String
            self.body = userInfo["body"] as? String
            self.badge = nil
            self.sound = nil
        }
        
        var customPayload: [String: Any] = [:]
        for (key, value) in userInfo {
            guard let strKey = key as? String, strKey != "aps" else { continue }
            customPayload[strKey] = value
        }
        self.payload = customPayload
    }
    
    public static func == (lhs: PushMessage, rhs: PushMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.body == rhs.body &&
               lhs.badge == rhs.badge &&
               lhs.sound == rhs.sound
    }
}
