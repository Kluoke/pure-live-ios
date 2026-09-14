import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredQuality") private var preferredQuality = "Auto"
    @AppStorage("danmakuEnabled") private var danmakuEnabled = true
    var body: some View {
        NavigationStack {
            Form {
                Picker("清晰度", selection: $preferredQuality) {
                    Text("自动").tag("Auto")
                    Text("原画").tag("Original")
                    Text("高清").tag("High")
                }
                Toggle("显示弹幕", isOn: $danmakuEnabled)
                Section("关于") { Text("Pure Live Native iOS") }
            }
            .navigationTitle("设置")
        }
    }
}
