import Foundation
import Archivable

public struct Archive: Arch {
    public static let version = UInt8()
    public static let new = Self()
    public var timestamp: UInt32
    public internal(set) var capacity: Int
    var secrets: [Secret]
    
    public var available: Bool {
        count < capacity
    }
    
    public var count: Int {
        secrets.count
    }
    
    public var data: Data {
        get async {
            await .init()
                .adding(UInt16(capacity))
                .adding(UInt16(secrets.count))
                .adding(secrets.flatMap(\.data))
                .encrypted
        }
    }
    
    private init() {
        timestamp = 0
        secrets = []
        capacity = 1
    }
    
    public subscript(_ index: Int) -> Secret {
        secrets.count > index
        ? secrets[index]
        : .new
    }
    
    public init(version: UInt8, timestamp: UInt32, data: Data) async {
        var data = await data.decrypted
        
        guard !data.isEmpty else {
            self.timestamp = 0
            secrets = []
            capacity = 1
            return
        }
        
        self.timestamp = timestamp
        secrets = []
        capacity = .init(data.uInt16())
        secrets = (0 ..< .init(data.uInt16()))
            .map { _ in
                .init(data: &data)
            }
    }
    
    public func filter(favourites: Bool, search: String) -> [Int] {
        secrets.filter(favourites: favourites, search: search)
    }
}
