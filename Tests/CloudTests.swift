import XCTest
import Combine
import Archivable
@testable import Secrets

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() async throws {
        cloud = .emphemeral
        subs = []
        _ = await cloud.secret()
        _ = await cloud.secret()
        _ = await cloud.secret()
        await cloud.delete(id: 1)
    }
    
    func testNew() async {
        let expect = expectation(description: "")
        let date = Date()
        
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(4, $0.secrets.count)
                XCTAssertEqual("Untitled", $0.secrets.first?.name)
                XCTAssertEqual("Untitled", $0.secrets.last?.name)
                XCTAssertGreaterThanOrEqual($0.timestamp, date.timestamp)
                XCTAssertGreaterThanOrEqual($0.secrets.first?.date.timestamp ?? 0, date.timestamp)
                XCTAssertGreaterThanOrEqual($0.secrets.last?.date.timestamp ?? 0, date.timestamp)
                XCTAssertFalse($0.available)
                expect.fulfill()
            }
            .store(in: &subs)
        
        let first = await cloud.secret()
        let second = await cloud.secret()
        
        XCTAssertEqual(1, first)
        XCTAssertEqual(3, second)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testIds() async {
        _ = await cloud.secret()
        _ = await cloud.secret()
        _ = await cloud.secret()
        _ = await cloud.secret()
        _ = await cloud.secret()
        
        let beforeDelete1 = await cloud.secret()
        XCTAssertEqual(7, beforeDelete1)
        
        await cloud.delete(id: 2)
        
        let afterDelete1 = await cloud.secret()
        let afterDelete2 = await cloud.secret()
        XCTAssertEqual(2, afterDelete1)
        XCTAssertEqual(8, afterDelete2)
        
        let id1 = await cloud._archive.secrets[cloud._archive.secrets.count - 2].id
        let id2 = await cloud._archive.secrets[cloud._archive.secrets.count - 1].id
        XCTAssertEqual(2, id1)
        XCTAssertEqual(8, id2)
    }
    
    func testDelete() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        await cloud.update(id: 2, name: "hello")
        let nameBefore = await cloud._archive.secrets[1].name
        XCTAssertEqual("hello", nameBefore)
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(2, $0.secrets.count)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.delete(id: 2)
        
        let nameAfter = await cloud._archive.secrets[1].name
        XCTAssertNotEqual("hello", nameAfter)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateName() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        await cloud.update(id: 2, name: "hello world")
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual("lorem ipsum", $0.secrets[1].name)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(id: 2, name: "lorem ipsum")
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateNameSame() async {
        _ = await cloud.secret()
        await cloud.update(id: 0, name: "hello world")
        
        cloud
            .archive
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(id: 0, name: "hello world")
    }
    
    func testUpdatePayload() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual("lorem ipsum", $0.secrets[1].payload)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(id: 2, payload: "lorem ipsum")
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdatePayloadSame() async {
        _ = await cloud.secret()
        await cloud.update(id: 0, payload: "hello world")
        
        cloud
            .archive
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(id: 0, payload: "hello world")
    }
    
    func testUpdateFavourite() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertTrue($0.secrets[1].favourite)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(id: 2, favourite: true)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateFavouriteSame() async {
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(id: 0, favourite: false)
    }
    
    func testAddTag() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertTrue($0.secrets[1].tags.contains(.books))
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(id: 2, tag: .books)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testAddTagSame() async {
        _ = await cloud.secret()
        await cloud.add(id: 0, tag: .important)
        
        cloud
            .archive
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.add(id: 0, tag: .important)
    }
    
    func testRemoveTag() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertFalse($0.secrets[1].tags.contains(.books))
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(id: 2, tag: .books)
        await cloud.remove(id: 2, tag: .books)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testRemoveTagSameNot() async {
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.remove(id: 0, tag: .important)
    }
    
    func testAddPurchase() async {
        let expect = expectation(description: "")
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(6, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(purchase: .five)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testRemovePurchase() async {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual(10, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(purchase: .ten)
        await cloud.remove(purchase: .one)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testRemoveNonZero() async {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(1, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.remove(purchase: .ten)
        
        await waitForExpectations(timeout: 1)
    }
}
