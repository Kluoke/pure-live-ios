import SwiftUI

struct ContentView: View {
    @State private var selectedPlatform: LivePlatform = .all

    var body: some View {
        NavigationStack {
            List {
                Section("Platforms") {
                    ForEach(LivePlatform.allCases) { platform in
                        Button {
                            selectedPlatform = platform
                        } label: {
                            HStack {
                                Image(systemName: platform.systemImage)
                                Text(platform.title)
                                Spacer()
                                if selectedPlatform == platform {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Native player") {
                    NavigationLink {
                        PlayerView(stream: .sample)
                    } label: {
                        Label("M3U8 Player", systemImage: "play.rectangle")
                    }
                }
            }
            .navigationTitle("Pure Live")
        }
    }
}

#Preview {
    ContentView()
}
