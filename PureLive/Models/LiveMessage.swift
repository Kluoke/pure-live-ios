import Foundation

struct LiveMessageColor: Codable, Hashable, Sendable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8

    static let white = LiveMessageColor(red: 255, green: 255, blue: 255)

    var hex: String { String(format: "#%02X%02X%02X", red, green, blue) }
}

enum LiveMessageType: String, Codable, Sendable {
    case chat
    case gift
    case online
    case superChat
}

struct LiveMessage: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let type: LiveMessageType
    let userName: String
    let message: String
    let data: String?
    let color: LiveMessageColor

    init(id: UUID = UUID(), type: LiveMessageType, userName: String, message: String, data: String? = nil, color: LiveMessageColor = .white) {
        self.id = id
        self.type = type
        self.userName = userName
        self.message = message
        self.data = data
        self.color = color
    }
}
