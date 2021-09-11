import Foundation
import Archivable

public struct Secret: Storable, Identifiable {
    static let new = Secret(id: 0, name: "", payload: "", date: .now, favourite: false, tags: [])
    
    public let id: Int
    public let name: String
    public let payload: String
    public let date: Date
    public let favourite: Bool
    public let tags: Set<Tag>
    
    public var data: Data {
        .init()
        .adding(UInt16(id))
        .adding(name)
        .adding(payload)
        .adding(date)
        .adding(favourite)
        .adding(UInt8(tags.count))
        .adding(tags.map(\.rawValue))
    }
    
    public init(data: inout Data) {
        id = .init(data.uInt16())
        name = data.string()
        payload = data.string()
        date = data.date()
        favourite = data.bool()
        tags = .init((0 ..< .init(data.removeFirst()))
                        .map { _ in
                            .init(rawValue: data.removeFirst())!
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
