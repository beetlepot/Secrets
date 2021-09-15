import Archivable

extension Cloud where A == Archive {    
    public func secret() async throws -> Int {
        guard
            _archive.available
        else {
            throw Failure.full
        }
        let id = self.id
        _archive
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
        _archive
            .secrets
            .remove(at: index)
        await stream()
    }
    
    public func update(id: Int, name: String) async {
        guard
            let index = index(id: id),
            name != _archive.secrets[index].name
        else { return }
        _archive
            .secrets
            .mutate(index: index) {
                $0.with(name: name)
            }
        await stream()
    }
    
    public func update(id: Int, payload: String) async {
        guard
            let index = index(id: id),
            payload != _archive.secrets[index].payload
        else { return }
        _archive
            .secrets
            .mutate(index: index) {
                $0.with(payload: payload)
            }
        await stream()
    }
    
    public func update(id: Int, favourite: Bool) async {
        guard
            let index = index(id: id),
            favourite != _archive.secrets[index].favourite
        else { return }
        _archive
            .secrets
            .mutate(index: index) {
                $0.with(favourite: favourite)
            }
        await stream()
    }
    
    public func add(id: Int, tag: Tag) async {
        guard
            let index = index(id: id),
            !_archive.secrets[index].tags.contains(tag)
        else { return }
        _archive
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
            _archive.secrets[index].tags.contains(tag)
        else { return }
        _archive
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .removing(tag))
            }
        await stream()
    }
    
    public func add(purchase: Purchase) async {
        _archive.capacity += purchase.value
        await stream()
    }
    
    public func remove(purchase: Purchase) async {
        _archive.capacity -= purchase.value
        _archive.capacity = max(_archive.capacity, 1)
        await stream()
    }
    
    private var id: Int {
        for index in (0 ..< 1_000) {
            if !_archive
                .secrets
                .contains(where: { $0.id == index }) {
                    return index
                }
        }
        return .init(UInt16.max)
    }
    
    func index(id: Int) -> Int? {
        _archive
            .secrets
            .firstIndex {
                $0.id == id
            }
    }
}
