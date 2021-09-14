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
        
        secret = secret.with(id: 99)
        secret = secret.with(name: "secret name")
        secret = secret.with(payload: "some payload")
        secret = secret.with(date: date)
        secret = secret.with(favourite: true)
        secret = secret.with(tags: [.pets, .food, .books])
        
        secret = secret.data.prototype()
        
        XCTAssertEqual(99, secret.id)
        XCTAssertEqual("secret name", secret.name)
        XCTAssertEqual("some payload", secret.payload)
        XCTAssertTrue(secret.favourite)
        XCTAssertTrue(secret.tags.contains(.pets))
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
                        .with(id: 88)
                        .with(name: "hello world")
                        .with(favourite: true),
                     .new
                        .with(id: 55)
                        .with(name: "hello world 2"),
                     .new
                        .with(id: 190)
                        .with(name: "lorem ipsum")
                        .with(favourite: true),
                     .new
                        .with(id: 33)
                        .with(name: "z")
                        .with(favourite: false)
                        .with(tags: [.top, .books])]
        
        var filter = Filter()
        XCTAssertEqual([88, 55, 190, 33], array.filtering(with: filter))
        
        filter.search = "alpha"
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.favourites = true
        filter.search = "2"
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.search = "E"
        XCTAssertEqual([88, 190], array.filtering(with: filter))
        
        filter.favourites = false
        filter.search = "hello"
        XCTAssertEqual([88, 55], array.filtering(with: filter))
        
        filter.tags = [.animals]
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.tags = [.top]
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.favourites = true
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.search = ""
        XCTAssertEqual([], array.filtering(with: filter))
        
        filter.favourites = false
        XCTAssertEqual([33], array.filtering(with: filter))
    }
}
