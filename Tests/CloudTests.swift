import XCTest
import Combine
import Archivable
@testable import Secrets

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        cloud = .ephemeral
        subs = []
    }
    
    func testNew() async {
        let date = Date()
        
        await stubs()
        let first = try! await cloud.secret()
        let second = try! await cloud.secret()
        
        XCTAssertEqual(1, first)
        XCTAssertEqual(3, second)
        
        let archive = await cloud.model
        
        XCTAssertEqual(4, archive.secrets.count)
        XCTAssertEqual("Untitled", archive.secrets.first?.name)
        XCTAssertEqual("Untitled", archive.secrets.last?.name)
        XCTAssertGreaterThanOrEqual(archive.timestamp, date.timestamp)
        XCTAssertGreaterThanOrEqual(archive.secrets.first?.date.timestamp ?? 0, date.timestamp)
        XCTAssertGreaterThanOrEqual(archive.secrets.last?.date.timestamp ?? 0, date.timestamp)
    }
    
    func testNewSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst()
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                try! await self.cloud.secret()
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateFullThrows() async {
        _ = try! await cloud.secret()
        do {
            _ = try await cloud.secret()
        } catch {
            return
        }
        XCTFail()
    }
    
    func testIds() async {
        await stubs()
        
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        
        let beforeDelete1 = try! await cloud.secret()
        XCTAssertEqual(7, beforeDelete1)
        
        await cloud.delete(id: 2)
        
        let afterDelete1 = try! await cloud.secret()
        let afterDelete2 = try! await cloud.secret()
        XCTAssertEqual(2, afterDelete1)
        XCTAssertEqual(8, afterDelete2)
        
        let id1 = await cloud.model.secrets[cloud.model.secrets.count - 2].id
        let id2 = await cloud.model.secrets[cloud.model.secrets.count - 1].id
        XCTAssertEqual(2, id1)
        XCTAssertEqual(8, id2)
    }
    
    func testDelete() async {
        await stubs()
        
        _ = try! await cloud.secret()
        await cloud.update(id: 2, name: "hello")
        let nameBefore = await cloud.model.secrets[1].name
        XCTAssertEqual("hello", nameBefore)
        
        await cloud.delete(id: 2)
        
        let archive = await cloud.model
        XCTAssertNotEqual("hello", archive.secrets[1].name)
        XCTAssertEqual(2, archive.secrets.count)
    }
    
    func testDeleteSaves() {
        let expect = expectation(description: "")

        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.delete(id: 0)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateName() async {
        await stubs()
        
        _ = try! await cloud.secret()
        await cloud.update(id: 2, name: "hello world")
        
        await cloud.update(id: 2, name: "lorem ipsum")
        
        let archive = await cloud.model
        XCTAssertEqual("lorem ipsum", archive.secrets[1].name)
    }
    
    func testUpdateNameSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, name: "lorem ipsum")
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateNameSameNotSaving() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, name: "hello world")
                await self.cloud.update(id: 0, name: "hello world")
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdatePayload() async {
        await stubs()
        _ = try! await cloud.secret()
        
        await cloud.update(id: 2, payload: "lorem ipsum")
        
        let archive = await cloud.model
        XCTAssertEqual("lorem ipsum", archive.secrets[1].payload)
    }
    
    func testUpdatePayloadSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, payload: "lorem ipsum")
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateNamePayload() async {
        await stubs()
        
        _ = try! await cloud.secret()
        await cloud.update(id: 2, name: "lorem ipsum", payload: "asd")
        
        let archive = await cloud.model
        XCTAssertEqual("lorem ipsum", archive.secrets[1].name)
        XCTAssertEqual("asd", archive.secrets[1].payload)
    }
    
    func testUpdateNamePayloadSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, name: "lorem ipsum", payload: "asd")
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdatePayloadSameNotSaving() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, payload: "hello world")
                await self.cloud.update(id: 0, payload: "hello world")
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateFavourite() async {
        await stubs()
        _ = try! await cloud.secret()
        
        await cloud.update(id: 2, favourite: true)
        
        let archive = await cloud.model
        XCTAssertTrue(archive.secrets[1].favourite)
    }
    
    func testUpdateFavouriteSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, favourite: true)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateFavouriteSameNotSaving() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst()
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.update(id: 0, favourite: false)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testAddTag() async {
        await stubs()
        _ = try! await cloud.secret()
        
        await cloud.add(id: 2, tag: .books)
        
        let archive = await cloud.model
        XCTAssertTrue(archive.secrets[1].tags.contains(.books))
    }
    
    func testAddTagSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.add(id: 0, tag: .books)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testAddTagSameNotSaving() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.add(id: 0, tag: .important)
                await self.cloud.add(id: 0, tag: .important)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRemoveTag() async {
        await stubs()
        _ = try! await cloud.secret()
        
        await cloud.add(id: 2, tag: .books)
        await cloud.remove(id: 2, tag: .books)
        
        let archive = await cloud.model
        XCTAssertFalse(archive.secrets[1].tags.contains(.books))
    }
    
    func testRemoveTagSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(3)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.add(id: 0, tag: .books)
                await self.cloud.remove(id: 0, tag: .books)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRemoveTagSameNotSaving() {
        let expect = expectation(description: "")
    
        cloud
            .dropFirst()
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                _ = try! await self.cloud.secret()
                await self.cloud.remove(id: 0, tag: .important)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testAddPurchase() async {
        await cloud.add(purchase: .five)
        
        let archive = await cloud.model
        XCTAssertEqual(6, archive.capacity)
    }
    
    func testAddPurchaseSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst()
            .sink {
                XCTAssertEqual(6, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                    await self.cloud.add(purchase: .five)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRemovePurchase() async {
        await cloud.add(purchase: .ten)
        await cloud.remove(purchase: .one)
        
        let archive = await cloud.model
        XCTAssertEqual(10, archive.capacity)
    }
    
    func testRemovePurchaseSaves() {
        let expect = expectation(description: "")
        
        cloud
            .dropFirst(2)
            .sink { _ in
                expect.fulfill()
            }
            .store(in: &subs)
        
        Task
            .detached {
                await self.cloud.add(purchase: .ten)
                await self.cloud.remove(purchase: .one)
            }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRemoveNonZero() async {
        await cloud.remove(purchase: .ten)
        
        let archive = await cloud.model
        XCTAssertEqual(1, archive.capacity)
    }
    
    private func stubs() async {
        await cloud.add(purchase: .ten)
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        _ = try! await cloud.secret()
        await cloud.delete(id: 1)
    }
}
