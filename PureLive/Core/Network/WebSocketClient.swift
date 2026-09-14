import Foundation

actor WebSocketClient {
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func connect(to url: URL, headers: [String: String] = [:]) {
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        task?.cancel()
        task = session.webSocketTask(with: request)
        task?.resume()
    }

    func send(_ text: String) async throws {
        guard let task else { throw WebSocketError.notConnected }
        try await task.send(.string(text))
    }

    func receive() async throws -> URLSessionWebSocketTask.Message {
        guard let task else { throw WebSocketError.notConnected }
        return try await task.receive()
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }
}

enum WebSocketError: Error {
    case notConnected
}
