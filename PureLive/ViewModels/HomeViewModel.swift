import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var keyword = ""
    var rooms: [LiveRoom] = []
    var isLoading = false
    var errorMessage: String?
    var platform: LivePlatform = .bilibili

    func search() async {
        let text = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { rooms = []; return }
        guard let service = PlatformRegistry.live.service(for: platform) else { return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { rooms = try await service.search(keyword: text) }
        catch { errorMessage = error.localizedDescription }
    }
}
