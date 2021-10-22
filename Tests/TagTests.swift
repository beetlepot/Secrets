import XCTest
@testable import Secrets

final class TagTests: XCTestCase {
    func testFilter() {
        XCTAssertEqual(Tag.allCases.sorted(), Tag.filtering(search: ""))
        XCTAssertEqual(Tag.allCases.sorted(), Tag.filtering(search: " "))
        XCTAssertTrue(Tag.filtering(search: "fsdfjdjkaddas").isEmpty)
        XCTAssertEqual([.codes], Tag.filtering(search: "codes"))
        XCTAssertEqual([.codes], Tag.filtering(search: "coDEs"))
        XCTAssertEqual([.codes, .keycode], Tag.filtering(search: "code"))
        XCTAssertTrue(Tag.filtering(search: "codesss").isEmpty)
        XCTAssertEqual([.codes], Tag.filtering(search: "codes something"))
        XCTAssertEqual([.codes, .top], Tag.filtering(search: "top something codes"))
    }
}
