import AVFoundation
import Combine
import Foundation

@MainActor
final class PlayerManager: ObservableObject {
    @Published private(set) var player: AVPlayer?
    @Published private(set) var isPlaying = false
    @Published private(set) var error: Error?

    func load(_ stream: LiveStream, autoplay: Bool = true) {
        error = nil
        let item = AVPlayerItem(url: stream.url)
        player = AVPlayer(playerItem: item)
        if autoplay { player?.play(); isPlaying = true }
    }

    func play() { player?.play(); isPlaying = true }
    func pause() { player?.pause(); isPlaying = false }
    func stop() { player?.pause(); player = nil; isPlaying = false }
}
