import Archivable

extension Cloud where Output == Archive {    
    public func secret() async throws -> Int {
        guard
            model.available
        else {
            throw SecretsError.full
        }
        let id = self.id
        model
            .secrets
            .append(
                .new
                    .with(id: id)
                    .with(name: "Untitled"))
        await stream()
        return id
    }
    
    public func delete(id: Int) async {
        guard let index = index(id: id) else { return }
        model
            .secrets
            .remove(at: index)
        await stream()
    }
    
    public func update(id: Int, name: String) async {
        guard
            let index = index(id: id),
            name != model.secrets[index].name
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(name: name)
            }
        await stream()
    }
    
    public func update(id: Int, payload: String) async {
        guard
            let index = index(id: id),
            payload != model.secrets[index].payload
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(payload: payload)
            }
        await stream()
    }
    
    public func update(id: Int, favourite: Bool) async {
        guard
            let index = index(id: id),
            favourite != model.secrets[index].favourite
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(favourite: favourite)
            }
        await stream()
    }
    
    public func add(id: Int, tag: Tag) async {
        guard
            let index = index(id: id),
            !model.secrets[index].tags.contains(tag)
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .inserting(tag))
            }
        await stream()
    }
    
    public func remove(id: Int, tag: Tag) async {
        guard
            let index = index(id: id),
            model.secrets[index].tags.contains(tag)
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .removing(tag))
            }
        await stream()
    }
    
    public func add(purchase: Purchase) async {
        model.capacity += purchase.value
        await stream()
    }
    
    public func remove(purchase: Purchase) async {
        model.capacity -= purchase.value
        model.capacity = Swift.max(model.capacity, 1)
        await stream()
    }
    
    private var id: Int {
        for index in (0 ..< 1_000) {
            if !model
                .secrets
                .contains(where: { $0.id == index }) {
                    return index
                }
        }
        return .init(UInt16.max)
    }
    
    func index(id: Int) -> Int? {
        model
            .secrets
            .firstIndex {
                $0.id == id
            }
    }
}
