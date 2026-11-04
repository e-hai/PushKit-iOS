import SwiftUI
import PushKit

struct ContentView: View {
    @State private var permissionStatusText = "检测中..."
    @State private var hasPermission = false
    @State private var tipMessage = ""
    @State private var showToast = false
    @State private var toastIcon = "checkmark.circle.fill"
    @State private var toastColor: Color = .green
    @State private var logHistory: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景微妙渐变
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - 顶部简洁头部
                        headerSection
                        
                        // MARK: - 权限状态卡片
                        permissionCard
                        
                        // MARK: - 功能测试区
                        notificationActionsSection
                        
                        // MARK: - 实时操作历史日志
                        if !logHistory.isEmpty {
                            logsSection
                        }
                        
                        // 底部说明
                        Text("PushKit for iOS • Pure Swift 5.9+ / SPM")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // MARK: - 浮动轻量 Toast
                if showToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: toastIcon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(toastColor)
                            Text(tipMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(toastColor.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showToast)
                }
            }
            .navigationBarHidden(true)
            .onAppear(perform: checkPermission)
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - 顶部头部
    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("PushKit")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("iOS")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                Text("轻量现代的 Swift 通知与 APNs 推送引擎")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 2)
        .padding(.top, 4)
    }
    
    // MARK: - 权限卡片
    private var permissionCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill((hasPermission ? Color.green : Color.orange).opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: hasPermission ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .font(.system(size: 15))
                            .foregroundColor(hasPermission ? .green : .orange)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("通知权限状态")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(permissionStatusText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(hasPermission ? "已开启" : "未开启")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((hasPermission ? Color.green : Color.orange).opacity(0.12))
                    .foregroundColor(hasPermission ? .green : .orange)
                    .clipShape(Capsule())
            }
            
            Divider()
                .opacity(0.5)
            
            HStack(spacing: 10) {
                Button(action: requestPermission) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 12))
                        Text("请求权限")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    PushKitManager.shared.openNotificationSettings()
                    addLog("打开系统设置")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                        Text("系统设置")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - 功能测试区
    private var notificationActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("功能场景演练")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 2)
            
            // 1. 普通即时通知
            ActionCardView(
                iconName: "bubble.left.and.bubble.right.fill",
                iconColor: .blue,
                title: "基础即时通知",
                badgeText: "即时",
                badgeColor: .blue,
                description: "使用 Swift DSL 链式构建，前台直接以 Banner 横幅弹出。",
                action: sendBasicNotification
            )
            
            // 2. 倒计时定时通知
            ActionCardView(
                iconName: "timer",
                iconColor: .orange,
                title: "倒计时定时通知",
                badgeText: "5秒后",
                badgeColor: .orange,
                description: "基于 UNTimeIntervalTrigger 触发，支持退到桌面或锁屏查看。",
                action: sendCountdownNotification
            )
            
            // 3. 交互式分类通知
            ActionCardView(
                iconName: "hand.point.up.left.and.text.fill",
                iconColor: .purple,
                title: "交互动作分类通知",
                badgeText: "带按钮",
                badgeColor: .purple,
                description: "挂载 DEMO_CATEGORY，长按或下拉可触发 [回复] 与 [忽略] 按钮交互。",
                action: sendCategoryNotification
            )
            
            // 4. 清除全部通知
            Button(action: clearAllNotifications) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                    Text("清空所有通知并重置角标")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
            }
        }
    }
    
    // MARK: - 实时日志列表
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("操作日志")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Button("清空") {
                    withAnimation { logHistory.removeAll() }
                }
                .font(.system(size: 11))
            }
            .padding(.horizontal, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(logHistory.prefix(3), id: \.self) { log in
                    Text(log)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }
    
    // MARK: - 业务逻辑方法
    
    private func checkPermission() {
        Task {
            let status = await PushKitManager.shared.permission.getPermissionStatus()
            let isGranted = await PushKitManager.shared.hasNotificationPermission()
            await MainActor.run {
                self.hasPermission = isGranted
                switch status {
                case .authorized:
                    self.permissionStatusText = "已授权 (Authorized)"
                case .denied:
                    self.permissionStatusText = "已拒绝 (Denied)"
                case .provisional:
                    self.permissionStatusText = "静默临时授权"
                case .ephemeral:
                    self.permissionStatusText = "临时授权"
                case .notDetermined:
                    self.permissionStatusText = "未确认 (Not Determined)"
                case .unknown:
                    self.permissionStatusText = "未知状态"
                }
            }
        }
    }
    
    private func requestPermission() {
        Task {
            do {
                let granted = try await PushKitManager.shared.requestPermission(options: [.alert, .badge, .sound])
                await MainActor.run {
                    self.checkPermission()
                    showBanner(
                        message: granted ? "通知权限获取成功！" : "权限被拒绝，可在系统设置开启",
                        icon: granted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                        color: granted ? .green : .orange
                    )
                    addLog("权限请求结果：\(granted ? "允许" : "拒绝")")
                }
            } catch {
                await MainActor.run {
                    showBanner(message: "请求失败：\(error.localizedDescription)", icon: "xmark.circle.fill", color: .red)
                    addLog("授权出错：\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendBasicNotification() {
        Task {
            do {
                let id = "demo_basic_\(Int(Date().timeIntervalSince1970))"
                try await PushKitManager.shared.notify(id: id) { builder in
                    builder.title = "新消息提醒"
                    builder.subtitle = "PushKit Swift DSL"
                    builder.body = "这是一条即时通知，前台直接呈现实时横幅。"
                    builder.badge = 1
                    builder.userInfo = ["source": "demo"]
                }
                await MainActor.run {
                    showBanner(message: "即时通知已发出！", icon: "paperplane.fill", color: .blue)
                    addLog("发送通知成功 [ID: \(id)]")
                }
            } catch {
                await MainActor.run {
                    showBanner(message: "发送失败：\(error.localizedDescription)", icon: "xmark.circle.fill", color: .red)
                    addLog("发送失败：\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendCountdownNotification() {
        Task {
            do {
                let id = "demo_timer_\(Int(Date().timeIntervalSince1970))"
                try await PushKitManager.shared.notify(id: id) { builder in
                    builder.title = "⏰ 倒计时定时通知"
                    builder.body = "5 秒倒计时结束，定时触发器运行正常。"
                    builder.triggerType = .timeInterval(seconds: 5, repeats: false)
                }
                await MainActor.run {
                    showBanner(message: "已提交 5 秒定时通知！可退回桌面观察", icon: "timer", color: .orange)
                    addLog("已注册 5 秒倒计时通知")
                }
            } catch {
                await MainActor.run {
                    showBanner(message: "提交定时失败：\(error.localizedDescription)", icon: "xmark.circle.fill", color: .red)
                }
            }
        }
    }
    
    private func sendCategoryNotification() {
        Task {
            do {
                let id = "demo_cat_\(Int(Date().timeIntervalSince1970))"
                try await PushKitManager.shared.notify(id: id) { builder in
                    builder.title = "💬 交互式分类通知"
                    builder.body = "长按或下拉此通知条目，即可呼出 [回复] 和 [忽略] 按钮。"
                    builder.categoryIdentifier = "DEMO_CATEGORY"
                }
                await MainActor.run {
                    showBanner(message: "分类通知已发送！长按通知横幅测试按钮", icon: "hand.tap.fill", color: .purple)
                    addLog("发送带 Action 交互分类通知成功")
                }
            } catch {
                await MainActor.run {
                    showBanner(message: "发送失败：\(error.localizedDescription)", icon: "xmark.circle.fill", color: .red)
                }
            }
        }
    }
    
    private func clearAllNotifications() {
        PushKitManager.shared.cancelAll()
        PushKitManager.shared.setBadgeCount(0)
        showBanner(message: "已清除全部通知，角标归零", icon: "trash.fill", color: .red)
        addLog("清除全部通知和角标")
    }
    
    private func showBanner(message: String, icon: String, color: Color) {
        self.tipMessage = message
        self.toastIcon = icon
        self.toastColor = color
        withAnimation {
            self.showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation {
                self.showToast = false
            }
        }
    }
    
    private func addLog(_ text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeStr = formatter.string(from: Date())
        withAnimation {
            self.logHistory.insert("[\(timeStr)] \(text)", at: 0)
        }
    }
}

// MARK: - 紧凑型场景卡片组件
struct ActionCardView: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let badgeText: String
    let badgeColor: Color
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(iconColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(badgeText)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(badgeColor.opacity(0.12))
                            .foregroundColor(badgeColor)
                            .cornerRadius(4)
                    }
                    
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(CardPressableStyle())
    }
}

struct CardPressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
