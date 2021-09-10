import Foundation

public enum Purchase: String, CaseIterable {
    case
    one = "beet.1",
    five = "beet.5",
    ten = "beet.10"
    
    public var save: Int {
        switch self {
        case .one:
            return 0
        case .five:
            return 40
        case .ten:
            return 50
        }
    }
    
    var value: Int {
        switch self {
        case .one:
            return 1
        case .five:
            return 5
        case .ten:
            return 10
        }
    }
}
