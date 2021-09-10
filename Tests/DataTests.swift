import XCTest
@testable import Secrets

final class DataTests: XCTestCase {
    override func setUp() {
        Security.key = .init(size: .bits256)
    }
    
    func testEncryption() async {
        let original = "hello world"
        let round = String(decoding: await Data(original.utf8).encrypted.decrypted, as: UTF8.self)
        XCTAssertEqual(round, original)
    }
}
