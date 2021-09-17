import Foundation

extension Sequence where Element == Tag {
    public var list: [String] {
        map(\.name).sorted()
    }
}
