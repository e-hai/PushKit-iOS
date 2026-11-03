import Foundation
import UserNotifications

/// Swift DSL 语法糖及辅助扩展。
extension PushKitManager {
    /// 以闭包形式快速构建并发送通知
    /// - Parameters:
    ///   - id: 通知唯一标识符（可选，默认自动生成 UUID）
    ///   - builder: 构建闭包
    /// - Returns: 生成的通知 Request ID
    @discardableResult
    public func notify(
        id: String = UUID().uuidString,
        _ builder: (PushNotificationBuilder) -> Void
    ) async throws -> String {
        let pushBuilder = PushNotificationBuilder()
        pushBuilder.id = id
        builder(pushBuilder)
        let request = try pushBuilder.build()
        try await post(request)
        return request.identifier
    }
}
