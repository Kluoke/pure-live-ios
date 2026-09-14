import Foundation

struct PlatformRegistry: Sendable {
    static let live = PlatformRegistry(services: [
        .bilibili: BilibiliService(),
        .douyu: DouyuService(),
        .huya: HuyaService(),
        .kuaishou: KuaishouService(),
        .douyin: DouyinService(),
        .neteaseCC: NetEaseCCService()
    ])

    private let services: [LivePlatform: any LivePlatformService]

    init(services: [LivePlatform: any LivePlatformService] = [:]) { self.services = services }
    func service(for platform: LivePlatform) -> (any LivePlatformService)? { services[platform] }
}
