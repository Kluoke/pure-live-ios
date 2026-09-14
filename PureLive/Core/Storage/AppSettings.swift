import Foundation

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var selectedPlatform: LivePlatform {
        didSet { UserDefaults.standard.set(selectedPlatform.rawValue, forKey: Keys.platform) }
    }

    @Published var preferredQuality: String {
        didSet { UserDefaults.standard.set(preferredQuality, forKey: Keys.quality) }
    }

    private enum Keys {
        static let platform = "selectedPlatform"
        static let quality = "preferredQuality"
    }

    private init() {
        selectedPlatform = LivePlatform(rawValue: UserDefaults.standard.string(forKey: Keys.platform) ?? "all") ?? .all
        preferredQuality = UserDefaults.standard.string(forKey: Keys.quality) ?? "Auto"
    }
}
