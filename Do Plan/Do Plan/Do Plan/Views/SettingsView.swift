import SwiftUI

struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("syncEnabled") private var syncEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("fontSize") private var fontSize = 1 // 0 小，1 中，2 大
    @State private var username = "小明"
    @State private var email = "xiaoming@example.com"
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息
                Section {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            
                            Text(String(username.prefix(1)))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(username)
                                .font(.headline)
                            
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // 编辑个人资料
                        }) {
                            Text("编辑")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 外观设置
                Section(header: Text("外观")) {
                    Toggle("深色模式", isOn: $darkMode)
                    
                    HStack {
                        Text("字体大小")
                        Spacer()
                        Picker("字体大小", selection: $fontSize) {
                            Text("小").tag(0)
                            Text("中").tag(1)
                            Text("大").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 180)
                    }
                    
                    NavigationLink(destination: ThemeSelectionView()) {
                        Text("主题颜色")
                    }
                }
                
                // 数据设置
                Section(header: Text("数据")) {
                    Toggle("启用同步", isOn: $syncEnabled)
                    
                    Button(action: {
                        // 导出数据
                    }) {
                        Text("导出数据")
                    }
                    
                    Button(action: {
                        // 导入数据
                    }) {
                        Text("导入数据")
                    }
                    
                    Button(action: {
                        // 清除所有数据
                    }) {
                        Text("清除所有数据")
                            .foregroundColor(.red)
                    }
                }
                
                // 通知设置
                Section(header: Text("通知")) {
                    Toggle("允许通知", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            Text("通知偏好设置")
                        }
                    }
                }
                
                // 关于和支持
                Section(header: Text("关于和支持")) {
                    NavigationLink(destination: Text("关于页面")) {
                        Label("关于", systemImage: "info.circle")
                    }
                    
                    NavigationLink(destination: Text("隐私政策页面")) {
                        Label("隐私政策", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("帮助与反馈页面")) {
                        Label("帮助与反馈", systemImage: "questionmark.circle")
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                // 版本信息
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                } footer: {
                    Text("© 2023 清悦笔记. 保留所有权利.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                }
            }
            .navigationTitle("设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert("确定要退出登录吗？", isPresented: $showingLogoutAlert) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    // 退出登录逻辑
                }
            } message: {
                Text("您的数据将保留在设备上，但不再自动同步。")
            }
        }
    }
}

struct ThemeSelectionView: View {
    @AppStorage("themeColor") private var themeColor = "blue"
    
    let themes = [
        ("蓝色", "blue", Color.blue),
        ("红色", "red", Color.red),
        ("绿色", "green", Color.green),
        ("紫色", "purple", Color.purple),
        ("橙色", "orange", Color.orange),
        ("粉色", "pink", Color.pink)
    ]
    
    var body: some View {
        List {
            ForEach(themes, id: \.1) { name, value, color in
                Button(action: {
                    themeColor = value
                }) {
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                        
                        Text(name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if themeColor == value {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("选择主题")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct NotificationSettingsView: View {
    @AppStorage("reminderNotifications") private var reminderNotifications = true
    @AppStorage("systemNotifications") private var systemNotifications = true
    @AppStorage("updateNotifications") private var updateNotifications = true
    
    var body: some View {
        List {
            Section(header: Text("通知类型")) {
                Toggle("提醒通知", isOn: $reminderNotifications)
                Toggle("系统通知", isOn: $systemNotifications)
                Toggle("更新通知", isOn: $updateNotifications)
            }
            
            Section(header: Text("勿扰模式")) {
                Text("自定义勿扰时间段")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("通知设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    SettingsView()
} 