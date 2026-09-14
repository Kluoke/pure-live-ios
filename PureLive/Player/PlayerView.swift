import AVKit
import SwiftUI

struct PlayerView: View {
    let stream: LiveStream
    @StateObject private var playerManager = PlayerManager()

    var body: some View {
        VideoPlayer(player: playerManager.player)
            .background(.black)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(stream.quality)
            .onAppear {
                playerManager.load(stream)
            }
            .onDisappear {
                playerManager.stop()
            }
    }
}
