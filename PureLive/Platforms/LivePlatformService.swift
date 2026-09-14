import Foundation

protocol LivePlatformService: Sendable {
    var platform: LivePlatform { get }
    func search(keyword: String) async throws -> [LiveRoom]
    func categories() async throws -> [LiveCategory]
    func streams(for room: LiveRoom) async throws -> [LiveStream]
    func messages(for room: LiveRoom) -> AsyncThrowingStream<LiveMessage, Error>
}

struct LiveCategory: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let children: [LiveCategory]
}
