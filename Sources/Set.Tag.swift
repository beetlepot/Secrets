import Foundation

extension Set where Element == Tag {
    public var list: [String] {
        sorted().map { "\($0)" }
    }
}
