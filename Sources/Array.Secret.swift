import Foundation

extension Array where Element == Secret {
    func filter(favourites: Bool, search: String) -> [Int] {
        filter {
                favourites
                ? $0.favourite
                : true
            }
            .filter { secret in
                { components in
                    components.isEmpty
                    ? true
                    : components.contains {
                        secret.name.localizedCaseInsensitiveContains($0)
                    }
                } (search
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: " ")
                    .filter {
                        !$0.isEmpty
                    })
            }
            .map(\.id)
    }
}
