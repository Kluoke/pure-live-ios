import Foundation

struct IPTVService: LivePlatformService {
    let platform: LivePlatform = .iptv

    func search(keyword: String) async throws -> [LiveRoom] {
        []
    }

    func categories() async throws -> [LiveCategory] {
        []
    }

    func streams(for room: LiveRoom) async throws -> [LiveStream] {
        guard let url = room.link else { return [] }
        return [LiveStream(url: url, quality: "Original")]
    }

    func messages(for room: LiveRoom) -> AsyncThrowingStream<LiveMessage, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}
