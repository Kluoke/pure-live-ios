import SwiftUI

struct ChatOverlay: View {
    let messages: [LiveMessage]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(messages.suffix(8)) { item in
                HStack {
                    Text(item.userName).font(.caption.bold())
                    Text(item.text).font(.caption)
                }
                .padding(6)
                .background(.black.opacity(0.35), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .allowsHitTesting(false)
    }
}
