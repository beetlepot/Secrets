import XCTest
import Combine
import Archivable
@testable import Secrets

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        cloud = .init()
        subs = []
    }
    
    func testNew() async {
        let expect = expectation(description: "")
        let date = Date()
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(2, $0.secrets.count)
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
        
        XCTAssertEqual(0, first)
        XCTAssertEqual(1, second)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testDelete() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink {
                XCTAssertTrue($0.secrets.isEmpty)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.delete(index: 0)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateName() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        await cloud.update(index: 0, name: "hello world")
        
        cloud
            .archive
            .sink {
                XCTAssertEqual("lorem ipsum", $0.secrets.first?.name)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, name: "lorem ipsum")
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateNameSame() async {
        _ = await cloud.secret()
        await cloud.update(index: 0, name: "hello world")
        
        cloud
            .archive
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, name: "hello world")
    }
    
    func testUpdatePayload() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink {
                XCTAssertEqual("lorem ipsum", $0.secrets.first?.payload)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, payload: "lorem ipsum")
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdatePayloadSame() async {
        _ = await cloud.secret()
        await cloud.update(index: 0, payload: "hello world")
        
        cloud
            .archive
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, payload: "hello world")
    }
    
    func testUpdateFavourite() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink {
                XCTAssertTrue($0.secrets.first?.favourite ?? false)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, favourite: true)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testUpdateFavouriteSame() async {
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.update(index: 0, favourite: false)
    }
    
    func testAddTag() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink {
                XCTAssertTrue($0.secrets.first?.tags.contains(.books) ?? false)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(index: 0, tag: .books)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testAddTagSame() async {
        _ = await cloud.secret()
        await cloud.add(index: 0, tag: .important)
        
        cloud
            .archive
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.add(index: 0, tag: .important)
    }
    
    func testRemoveTag() async {
        let expect = expectation(description: "")
        _ = await cloud.secret()
        
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertFalse($0.secrets.first?.tags.contains(.books) ?? true)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.add(index: 0, tag: .books)
        await cloud.remove(index: 0, tag: .books)
        
        await waitForExpectations(timeout: 1)
    }
    
    func testRemoveTagSameNot() async {
        _ = await cloud.secret()
        
        cloud
            .archive
            .sink { _ in
                XCTFail()
            }
            .store(in: &subs)
        
        await cloud.remove(index: 0, tag: .important)
    }
    
    func testAddPurchase() async {
        let expect = expectation(description: "")
        
        cloud
            .archive
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
            .dropFirst()
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
            .sink {
                XCTAssertEqual(1, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        
        await cloud.remove(purchase: .ten)
        
        await waitForExpectations(timeout: 1)
    }
}
