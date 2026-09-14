import SwiftUI

struct RoomView: View {
    let room: LiveRoom
    @State private var streams: [LiveStream] = []
    @State private var selectedStream: LiveStream?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @AppStorage("danmakuEnabled") private var danmakuEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selectedStream {
                    PlayerView(stream: selectedStream)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ContentUnavailableView("等待播放", systemImage: "play.slash", description: Text("正在获取直播流"))
                        .frame(maxWidth: .infinity, minHeight: 220)
                }
                Text(room.title).font(.title3.bold())
                Text("\(room.nick) · \(room.platform.title)").foregroundStyle(.secondary)
                if !streams.isEmpty {
                    Picker("清晰度", selection: Binding(get: { selectedStream?.id ?? streams[0].id }, set: { id in selectedStream = streams.first { $0.id == id } })) {
                        ForEach(streams) { Text($0.quality).tag($0.id) }
                    }.pickerStyle(.menu)
                }
                if isLoading { ProgressView("获取直播流…") }
                if let errorMessage { Text(errorMessage).foregroundStyle(.red).font(.footnote) }
                if danmakuEnabled { Text("弹幕：平台适配器已预留，待接入对应协议").font(.caption).foregroundStyle(.secondary) }
            }.padding()
        }
        .navigationTitle("直播间")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        guard let service = PlatformRegistry.live.service(for: room.platform) else { isLoading = false; errorMessage = "未找到平台适配器"; return }
        do {
            streams = try await service.streams(for: room)
            selectedStream = streams.first
            isLoading = false
            if streams.isEmpty { errorMessage = "该平台暂时没有可用直播流" }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
