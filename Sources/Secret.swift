import Foundation
import Archivable

public struct Secret: Storable {
    public static let new = Secret(name: "", payload: "", date: .now, favourite: false, tags: [])
    public let name: String
    public let payload: String
    public let date: Date
    public let favourite: Bool
    public let tags: Set<Tag>
    
    public var data: Data {
        .init()
        .adding(name)
        .adding(payload)
        .adding(date)
        .adding(favourite)
        .adding(UInt8(tags.count))
        .adding(tags.map(\.rawValue))
    }
    
    public init(data: inout Data) {
        name = data.string()
        payload = data.string()
        date = data.date()
        favourite = data.bool()
        tags = .init((0 ..< .init(data.removeFirst()))
                        .map { _ in
                            .init(rawValue: data.removeFirst())!
                        })
    }
    
    private init(name: String, payload: String, date: Date, favourite: Bool, tags: Set<Tag>) {
        self.name = name
        self.payload = payload
        self.date = date
        self.favourite = favourite
        self.tags = tags
    }
    
    func with(name: String) -> Self {
        .init(name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(payload: String) -> Self {
        .init(name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(favourite: Bool) -> Self {
        .init(name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(tags: Set<Tag>) -> Self {
        .init(name: name, payload: payload, date: .init(), favourite: favourite, tags: tags)
    }
    
    func with(date: Date) -> Self {
        .init(name: name, payload: payload, date: date, favourite: favourite, tags: tags)
    }
}
