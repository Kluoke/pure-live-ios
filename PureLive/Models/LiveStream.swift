import Foundation

struct LiveStream: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let url: URL
    let quality: String
    let headers: [String: String]

    init(id: UUID = UUID(), url: URL, quality: String = "Auto", headers: [String: String] = [:]) {
        self.id = id
        self.url = url
        self.quality = quality
        self.headers = headers
    }

    static let sample = LiveStream(url: URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!, quality: "Sample")
}
