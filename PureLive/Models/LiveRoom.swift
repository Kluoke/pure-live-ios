import Foundation

struct LiveRoom: Codable, Hashable, Identifiable, Sendable {
    var roomId: String?
    var userId: String?
    var link: URL?
    var title: String
    var nick: String
    var avatar: URL?
    var cover: URL?
    var area: String
    var watching: String
    var followers: String
    var platform: LivePlatform
    var introduction: String?
    var notice: String?
    var status: Bool
    var isRecord: Bool
    var liveStatus: String
    var epgId: String?
    var currentProgramme: String?
    var currentProgrammeDescription: String?
    var catchUpURL: URL?
    var isCatchUp: Bool
    var catchUpStart: Int?
    var catchUpEnd: Int?

    var id: String {
        "\(platform.rawValue):\(roomId ?? link?.absoluteString ?? title)"
    }

    init(
        roomId: String? = nil,
        userId: String? = nil,
        link: URL? = nil,
        title: String = "",
        nick: String = "",
        avatar: URL? = nil,
        cover: URL? = nil,
        area: String = "",
        watching: String = "0",
        followers: String = "0",
        platform: LivePlatform = .all,
        introduction: String? = nil,
        notice: String? = nil,
        status: Bool = false,
        isRecord: Bool = false,
        liveStatus: String = "offline",
        epgId: String? = nil,
        currentProgramme: String? = nil,
        currentProgrammeDescription: String? = nil,
        catchUpURL: URL? = nil,
        isCatchUp: Bool = false,
        catchUpStart: Int? = nil,
        catchUpEnd: Int? = nil
    ) {
        self.roomId = roomId
        self.userId = userId
        self.link = link
        self.title = title
        self.nick = nick
        self.avatar = avatar
        self.cover = cover
        self.area = area
        self.watching = watching
        self.followers = followers
        self.platform = platform
        self.introduction = introduction
        self.notice = notice
        self.status = status
        self.isRecord = isRecord
        self.liveStatus = liveStatus
        self.epgId = epgId
        self.currentProgramme = currentProgramme
        self.currentProgrammeDescription = currentProgrammeDescription
        self.catchUpURL = catchUpURL
        self.isCatchUp = isCatchUp
        self.catchUpStart = catchUpStart
        self.catchUpEnd = catchUpEnd
    }
}
