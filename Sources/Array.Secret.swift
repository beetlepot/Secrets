import Foundation

extension Array where Element == Secret {
    func filtering(with: Filter) -> Self {
        filter {
            with.favourites
            ? $0.favourite
            : true
        }
        .filter {
            with.tags.isEmpty
            ? true
            : $0.tags.contains(where: with.tags.contains)
        }
        .filter { secret in
            { components in
                components.isEmpty
                ? true
                : components.contains {
                    secret.name.localizedCaseInsensitiveContains($0)
                }
            } (with.search
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: " ")
                .filter {
                !$0.isEmpty
            })
        }
    }
}
