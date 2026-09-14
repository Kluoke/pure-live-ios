import SwiftUI

struct RoomView: View {
    let room: LiveRoom
    @State private var streams: [LiveStream] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if let stream = streams.first {
                PlayerView(stream: stream)
            } else if isLoading {
                ProgressView("获取播放地址…")
            } else {
                ContentUnavailableView("暂无播放地址", systemImage: "play.slash", description: Text(error ?? "该直播间当前无法播放"))
            }
        }
        .navigationTitle(room.title)
        .task { await load() }
    }

    private func load() async {
        guard let service = PlatformRegistry.live.service(for: room.platform) else { isLoading = false; return }
        do { streams = try await service.streams(for: room) }
        catch { error = error.localizedDescription }
        isLoading = false
    }
}
