import Foundation

public struct Filter {
    public var search = ""
    public var favourites = false
    public var tags = Set<Tag>()
    
    public init() {
        
    }
}
