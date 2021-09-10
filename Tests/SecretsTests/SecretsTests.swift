import XCTest
@testable import Secrets

final class SecretsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Secrets().text, "Hello, World!")
    }
}
