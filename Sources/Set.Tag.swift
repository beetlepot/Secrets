import Foundation

extension Set where Element == Tag {
    public var list: [String] {
        map(\.name).sorted()
    }
}
