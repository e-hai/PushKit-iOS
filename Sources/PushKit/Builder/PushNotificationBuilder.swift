import Foundation
import UserNotifications

/// iOS 通知触发器类型枚举。
public enum NotificationTriggerType: Sendable {
    /// 立即触发
    case immediate
    /// 经过指定秒数倒计时后触发
    case timeInterval(seconds: TimeInterval, repeats: Bool)
    /// 指定具体日期组件触发（例如每天上午 9 点）
    case calendar(dateComponents: DateComponents, repeats: Bool)
}

/// iOS 富媒体附件配置。
public struct NotificationAttachmentConfig: @unchecked Sendable {
    /// 附件文件本地文件 URL (支持 jpg, png, mp4, mp3 等)
    public let fileURL: URL
    /// 附件唯一标识
    public let identifier: String
    /// 附件自定义选项
    public let options: [AnyHashable: Any]?
    
    public init(identifier: String = UUID().uuidString, fileURL: URL, options: [AnyHashable: Any]? = nil) {
        self.identifier = identifier
        self.fileURL = fileURL
        self.options = options
    }
}

/// 通知链式与 DSL 构建器类。
public final class PushNotificationBuilder {
    /// 通知唯一标识 ID（相同 ID 将覆盖更新现有通知）
    public var id: String = UUID().uuidString
    
    /// 通知标题
    public var title: String?
    
    /// 通知副标题
    public var subtitle: String?
    
    /// 通知正文内容
    public var body: String?
    
    /// 应用角标显示数值
    public var badge: NSNumber?
    
    /// 自定义提示音名称（为 nil 时使用默认系统声音）
    public var soundName: String?
    
    /// 通知所属分类 Identifier（与 NotificationCategoryConfig 对应）
    public var categoryIdentifier: String?
    
    /// 自定义业务数据字典
    public var userInfo: [AnyHashable: Any] = [:]
    
    /// 折叠分组标识符（相同 threadIdentifier 的通知在通知栏折叠为一组）
    public var threadIdentifier: String?
    
    /// 触发机制
    public var triggerType: NotificationTriggerType = .immediate
    
    /// 富媒体附件列表
    public var attachments: [NotificationAttachmentConfig] = []
    
    public init() {}
    
    /// 添加快捷动作或富文本附件
    public func addAttachment(fileURL: URL, identifier: String = UUID().uuidString) {
        attachments.append(NotificationAttachmentConfig(identifier: identifier, fileURL: fileURL))
    }
    
    /// 构建 UNNotificationRequest 请求对象
    public func build() throws -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        
        if let title = title { content.title = title }
        if let subtitle = subtitle { content.subtitle = subtitle }
        if let body = body { content.body = body }
        if let badge = badge { content.badge = badge }
        
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        } else {
            content.sound = .default
        }
        
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        if let threadIdentifier = threadIdentifier {
            content.threadIdentifier = threadIdentifier
        }
        
        content.userInfo = userInfo
        
        // 装配附件
        var nativeAttachments: [UNNotificationAttachment] = []
        for att in attachments {
            let nativeAtt = try UNNotificationAttachment(
                identifier: att.identifier,
                url: att.fileURL,
                options: att.options
            )
            nativeAttachments.append(nativeAtt)
        }
        content.attachments = nativeAttachments
        
        // 装配触发器
        let nativeTrigger: UNNotificationTrigger?
        switch triggerType {
        case .immediate:
            nativeTrigger = nil
        case .timeInterval(let seconds, let repeats):
            nativeTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(seconds, 0.1),
                repeats: repeats
            )
        case .calendar(let dateComponents, let repeats):
            nativeTrigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: repeats
            )
        }
        
        return UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: nativeTrigger
        )
    }
}
