import SwiftUI

struct HomeView: View {
    @State private var model = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("平台", selection: $model.platform) {
                        ForEach(LivePlatform.allCases.filter { $0 != .all }) { Text($0.title).tag($0) }
                    }
                    TextField("搜索直播间或主播", text: $model.keyword)
                        .textInputAutocapitalization(.never)
                        .onSubmit { Task { await model.search() } }
                }
                if model.isLoading { ProgressView().frame(maxWidth: .infinity) }
                if let error = model.errorMessage { Text(error).foregroundStyle(.red) }
                ForEach(model.rooms) { room in
                    NavigationLink {
                        RoomView(room: room)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(room.title).lineLimit(2)
                            Text("\(room.nick) · \(room.area)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Pure Live")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("搜索") { Task { await model.search() } } } }
        }
    }
}
