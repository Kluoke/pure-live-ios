import Foundation

struct M3U8Parser: Sendable {
    func resolveURL(_ playlistURL: URL, contents: String) -> [LiveStream] {
        let lines = contents.split(whereSeparator: \.isNewline).map(String.init)
        var streams: [LiveStream] = []

        for index in lines.indices where lines[index].hasPrefix("#EXT-X-STREAM-INF") {
            guard index + 1 < lines.count,
                  let url = URL(string: lines[index + 1], relativeTo: playlistURL)?.absoluteURL else {
                continue
            }
            let quality = qualityName(from: lines[index])
            streams.append(LiveStream(url: url, quality: quality))
        }

        if streams.isEmpty {
            streams.append(LiveStream(url: playlistURL, quality: "Original"))
        }
        return streams
    }

    private func qualityName(from tag: String) -> String {
        let attributes = tag.split(separator: ",")
        if let resolution = attributes.first(where: { $0.hasPrefix("RESOLUTION=") }) {
            return String(resolution.split(separator: "=").last ?? "Auto")
        }
        if let bandwidth = attributes.first(where: { $0.hasPrefix("BANDWIDTH=") }) {
            return "\(bandwidth.split(separator: "=").last ?? "Auto") bps"
        }
        return "Auto"
    }
}
