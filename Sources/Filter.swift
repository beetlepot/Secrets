import Foundation

public struct Filter: Equatable {
    public var search = ""
    public var favourites = false
    public var tags = Set<Tag>()
    
    public init() {
        
    }
}
