import XCTest
@testable import PushKit
import UserNotifications

final class PushKitTests: XCTestCase {
    func testPushMessageParsing() {
        let sampleUserInfo: [AnyHashable: Any] = [
            "aps": [
                "alert": [
                    "title": "测试推送",
                    "subtitle": "副标题",
                    "body": "推送正文内容"
                ],
                "badge": 5,
                "sound": "custom.caf"
            ],
            "custom_key": "custom_value",
            "id": "msg_12345"
        ]
        
        let message = PushMessage(userInfo: sampleUserInfo)
        XCTAssertEqual(message.id, "msg_12345")
        XCTAssertEqual(message.title, "测试推送")
        XCTAssertEqual(message.subtitle, "副标题")
        XCTAssertEqual(message.body, "推送正文内容")
        XCTAssertEqual(message.badge, 5)
        XCTAssertEqual(message.sound, "custom.caf")
        XCTAssertEqual(message.payload["custom_key"] as? String, "custom_value")
    }
    
    func testNotificationBuilder() throws {
        let builder = PushNotificationBuilder()
        builder.id = "test_noti_id"
        builder.title = "DSL 标题"
        builder.subtitle = "DSL 副标题"
        builder.body = "DSL 内容"
        builder.badge = 3
        builder.userInfo = ["from": "unit_test"]
        builder.triggerType = .timeInterval(seconds: 10, repeats: false)
        
        let request = try builder.build()
        XCTAssertEqual(request.identifier, "test_noti_id")
        XCTAssertEqual(request.content.title, "DSL 标题")
        XCTAssertEqual(request.content.subtitle, "DSL 副标题")
        XCTAssertEqual(request.content.body, "DSL 内容")
        XCTAssertEqual(request.content.badge, 3)
        XCTAssertEqual(request.content.userInfo["from"] as? String, "unit_test")
        XCTAssertNotNil(request.trigger)
    }
    
    func testCategoryConfig() {
        let action = PushNotificationActionConfig(identifier: "ACTION_REPLY", title: "回复", options: [.foreground])
        let category = NotificationCategoryConfig(
            identifier: "CATEGORY_MESSAGE",
            actions: [action],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "%u 条新消息"
        )
        
        let native = category.toNativeCategory()
        XCTAssertEqual(native.identifier, "CATEGORY_MESSAGE")
        XCTAssertEqual(native.actions.count, 1)
        XCTAssertEqual(native.actions.first?.identifier, "ACTION_REPLY")
    }
}
