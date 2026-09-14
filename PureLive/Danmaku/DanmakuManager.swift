import Foundation

@MainActor
final class DanmakuManager: ObservableObject {
    @Published private(set) var messages: [LiveMessage] = []

    func append(_ message: LiveMessage) {
        messages.append(message)
        if messages.count > 500 {
            messages.removeFirst(messages.count - 500)
        }
    }

    func clear() {
        messages.removeAll(keepingCapacity: true)
    }
}
