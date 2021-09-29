import Foundation
import Archivable

public struct Secret: Storable, Identifiable, Equatable {
    public static let new = Secret(id: .init(UInt16.max), name: "", payload: "", date: .now, favourite: false, tags: [])
    
    public let id: Int
    public let name: String
    public let payload: String
    public let date: Date
    public let favourite: Bool
    public let tags: Set<Tag>
    
    public var data: Data {
        .init()
        .adding(UInt16(id))
        .adding(UInt16.self, string: name)
        .adding(UInt16.self, string: payload)
        .adding(date)
        .adding(favourite)
        .wrapping(UInt8.self, data: .init(tags.map(\.rawValue)))
    }
    
    public init(data: inout Data) {
        id = .init(data.number() as UInt16)
        name = data.string(UInt16.self)
        payload = data.string(UInt16.self)
        date = data.date()
        favourite = data.bool()
        tags = .init(data
            .unwrap(UInt8.self)
                        .map {
                            .init(rawValue: $0)!
                        })
    }
    
    private init(id: Int, name: String, payload: String, date: Date, favourite: Bool, tags: Set<Tag>) {
        self.id = id
        self.name = name
        self.payload = payload
        self.date = date
        self.favourite = favourite
        self.tags = tags
    }
    
    func with(id: Int) -> Self {
        .init(id: id, name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(name: String) -> Self {
        .init(id: id, name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(payload: String) -> Self {
        .init(id: id, name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(favourite: Bool) -> Self {
        .init(id: id, name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(tags: Set<Tag>) -> Self {
        .init(id: id, name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(date: Date) -> Self {
        .init(id: id, name: name, payload: payload, date: date, favourite: favourite, tags: tags)
    }
}
