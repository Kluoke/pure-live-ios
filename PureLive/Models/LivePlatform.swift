import Foundation

/// Native live-stream providers supported by the application.
enum LivePlatform: String, CaseIterable, Identifiable, Codable, Sendable {
    case all
    case bilibili
    case douyu
    case huya
    case kuaishou
    case douyin
    case neteaseCC

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .bilibili: return "哔哩哔哩"
        case .douyu: return "斗鱼"
        case .huya: return "虎牙"
        case .kuaishou: return "快手"
        case .douyin: return "抖音"
        case .neteaseCC: return "网易CC"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .bilibili: return "play.tv"
        case .douyu, .huya, .kuaishou, .douyin, .neteaseCC: return "dot.radiowaves.left.and.right"
        }
    }
}
