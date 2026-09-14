import XCTest
@testable import PureLiveCore

final class PureLiveCoreTests: XCTestCase {
    func testPackageVersion() {
        XCTAssertEqual(PureLiveCorePackage.version, "0.1.0")
    }
}
