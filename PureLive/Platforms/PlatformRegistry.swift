import Foundation

struct PlatformRegistry: Sendable {
    private let services: [LivePlatform: any LivePlatformService]

    init(services: [LivePlatform: any LivePlatformService] = [:]) {
        self.services = services
    }

    func service(for platform: LivePlatform) -> (any LivePlatformService)? {
        services[platform]
    }
}
