import XCTest
@testable import Secrets

final class SecretTests: XCTestCase {
    private var secret: Secret!
    
    override func setUp() {
        secret = .new
    }
    
    func testFavourite() {
        XCTAssertFalse(secret.favourite)
    }
    
    func testTags() {
        XCTAssertTrue(secret.tags.isEmpty)
    }
    
    func testData() {
        let date = Date(timeIntervalSinceNow: -10000)
        
        secret = secret.with(name: "secret name")
        secret = secret.with(payload: "some payload")
        secret = secret.with(date: date)
        secret = secret.with(favourite: true)
        secret = secret.with(tags: [.pet, .food, .books])
        
        secret = secret.data.prototype()
        
        XCTAssertEqual("secret name", secret.name)
        XCTAssertEqual("some payload", secret.payload)
        XCTAssertTrue(secret.favourite)
        XCTAssertTrue(secret.tags.contains(.pet))
        XCTAssertTrue(secret.tags.contains(.food))
        XCTAssertTrue(secret.tags.contains(.books))
    }
    
    func testNameDate() {
        let date = Date.now
        secret = secret.with(date: .init(timeIntervalSinceNow: -10000))
        secret = secret.with(name: "lol")
        XCTAssertGreaterThanOrEqual(secret.date, date)
    }
    
    func testPayloadDate() {
        let date = Date.now
        secret = secret.with(date: .init(timeIntervalSinceNow: -10000))
        secret = secret.with(payload: "asd")
        XCTAssertGreaterThanOrEqual(secret.date, date)
    }
    
    func testFavouriteDate() {
        let date = Date.now
        secret = secret.with(date: .init(timeIntervalSinceNow: -10000))
        secret = secret.with(favourite: true)
        XCTAssertGreaterThanOrEqual(secret.date, date)
    }
    
    func testTagsDate() {
        let date = Date.now
        secret = secret.with(date: .init(timeIntervalSinceNow: -10000))
        secret = secret.with(tags: [.books])
        XCTAssertGreaterThanOrEqual(secret.date, date)
    }
    
    func testFilter() {
        let array = [Secret.new
                        .with(name: "hello world")
                        .with(favourite: true),
                     .new
                        .with(name: "hello world 2"),
                     .new
                        .with(name: "lorem ipsum")
                        .with(favourite: true)]
        XCTAssertEqual([0, 1, 2], array.filter(favourites: false, search: ""))
        XCTAssertEqual([], array.filter(favourites: false, search: "alpha"))
        XCTAssertEqual([], array.filter(favourites: true, search: "2"))
        XCTAssertEqual([0, 2], array.filter(favourites: true, search: "e"))
        XCTAssertEqual([0, 1], array.filter(favourites: false, search: "hello"))
    }
}
