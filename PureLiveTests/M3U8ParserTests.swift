import XCTest
@testable import PureLive

final class M3U8ParserTests: XCTestCase {
    func testMasterPlaylistParsesVariants() throws {
        let text = """
        #EXTM3U
        #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
        low.m3u8
        #EXT-X-STREAM-INF:BANDWIDTH=2500000,RESOLUTION=1280x720
        high.m3u8
        """
        let url = URL(string: "https://example.com/live/master.m3u8")!
        let result = M3U8Parser().parse(text, baseURL: url)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].quality, "640x360")
        XCTAssertEqual(result[1].url.absoluteString, "https://example.com/live/high.m3u8")
    }
}
