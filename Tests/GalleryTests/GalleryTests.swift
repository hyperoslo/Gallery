import XCTest
@testable import Gallery

final class GalleryTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Gallery().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
