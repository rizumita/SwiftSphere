import XCTest
@testable import SwiftSphere

final class SwiftSphereTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftSphere().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
