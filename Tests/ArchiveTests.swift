import XCTest
@testable import Archivable
@testable import Secrets

final class ArchiveTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        Security.key = .init(size: .bits256)
        archive = .new
    }
    
    func testCapacity() async {
        XCTAssertEqual(1, archive.capacity)
        archive.capacity = 100
        archive = await Archive.prototype(data: archive.compressed)
        XCTAssertEqual(100, archive.capacity)
    }
    
    func testAvailable() {
        XCTAssertTrue(archive.available)
        archive.secrets = [.new]
        XCTAssertFalse(archive.available)
    }
    
    func testSecrets() async {
        XCTAssertTrue(archive.secrets.isEmpty)
        archive.secrets.append(.new
                                .with(payload: "hello"))
        archive = await Archive.prototype(data: archive.compressed)
        XCTAssertEqual(1, archive.secrets.count)
        XCTAssertEqual("hello", archive.secrets.first?.payload)
    }
    
    func testDecryptingFails() async {
        archive.capacity = 10
        archive.secrets.append(.new
                                .with(payload: "hello"))
        let compressed = await archive.compressed
        Security.key = .init(size: .bits256)
        
        archive = await Archive.prototype(data: compressed)
        XCTAssertTrue(archive.secrets.isEmpty)
        XCTAssertEqual(1, archive.capacity)
    }
    
    func testInvalidIndex() async {
        XCTAssertEqual(.new, archive[1])
        XCTAssertEqual(.new, archive[0])
        XCTAssertEqual(.new, archive[2])
    }
}
