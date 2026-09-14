import Foundation

/// Placeholder adapters keep the native architecture stable while each upstream
/// provider's protocol/signing implementation is migrated independently.
struct UnsupportedPlatformService: LivePlatformService {
    let platform: LivePlatform

    func search(keyword: String) async throws -> [LiveRoom] { [] }
    func categories() async throws -> [LiveCategory] { [] }
    func streams(for room: LiveRoom) async throws -> [LiveStream] { [] }
    func messages(for room: LiveRoom) -> AsyncThrowingStream<LiveMessage, Error> {
        AsyncThrowingStream { continuation in continuation.finish() }
    }
}
