import Foundation

/// Live-stream platforms supported by the native application.
enum LivePlatform: String, CaseIterable, Identifiable, Codable, Sendable {
    case all
    case bilibili
    case douyu
    case huya
    case kuaishou
    case douyin
    case neteaseCC
    case iptv

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .bilibili: return "Bilibili"
        case .douyu: return "Douyu"
        case .huya: return "Huya"
        case .kuaishou: return "Kuaishou"
        case .douyin: return "Douyin"
        case .neteaseCC: return "NetEase CC"
        case .iptv: return "M3U8 / IPTV"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .bilibili: return "play.tv"
        case .douyu, .huya, .kuaishou, .douyin, .neteaseCC: return "dot.radiowaves.left.and.right"
        case .iptv: return "antenna.radiowaves.left.and.right"
        }
    }
}
