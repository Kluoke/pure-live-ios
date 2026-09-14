import XCTest
@testable import PureLive

final class PureLiveTests: XCTestCase {
    func testLivePlatformList() {
        XCTAssertTrue(LivePlatform.allCases.contains(.bilibili))
        XCTAssertTrue(LivePlatform.allCases.contains(.douyu))
        XCTAssertTrue(LivePlatform.allCases.contains(.huya))
        XCTAssertFalse(LivePlatform.allCases.map(\.rawValue).contains("iptv"))
    }

    func testM3U8ParserFallback() {
        let url = URL(string: "https://example.com/live/index.m3u8")!
        let streams = M3U8Parser.parse("#EXTM3U\n#EXT-X-TARGETDURATION:6\n", baseURL: url)
        XCTAssertEqual(streams.count, 1)
        XCTAssertEqual(streams.first?.url, url)
    }
}
