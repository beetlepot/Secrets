import Archivable
import Darwin

extension Cloud where A == Archive {    
    public func secret() async -> Int {
        let id = self.id
        arch
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
        arch
            .secrets
            .remove(at: index)
        await stream()
    }
    
    public func update(id: Int, name: String) async {
        guard
            let index = index(id: id),
            name != arch.secrets[index].name
        else { return }
        arch
            .secrets
            .mutate(index: index) {
                $0.with(name: name)
            }
        await stream()
    }
    
    public func update(id: Int, payload: String) async {
        guard
            let index = index(id: id),
            payload != arch.secrets[index].payload
        else { return }
        arch
            .secrets
            .mutate(index: index) {
                $0.with(payload: payload)
            }
        await stream()
    }
    
    public func update(id: Int, favourite: Bool) async {
        guard
            let index = index(id: id),
            favourite != arch.secrets[index].favourite
        else { return }
        arch
            .secrets
            .mutate(index: index) {
                $0.with(favourite: favourite)
            }
        await stream()
    }
    
    public func add(id: Int, tag: Tag) async {
        guard
            let index = index(id: id),
            !arch.secrets[index].tags.contains(tag)
        else { return }
        arch
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
            arch.secrets[index].tags.contains(tag)
        else { return }
        arch
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .removing(tag))
            }
        await stream()
    }
    
    public func add(purchase: Purchase) async {
        arch.capacity += purchase.value
        await stream()
    }
    
    public func remove(purchase: Purchase) async {
        arch.capacity -= purchase.value
        arch.capacity = max(arch.capacity, 1)
        await stream()
    }
    
    private var id: Int {
        for index in (0 ..< 1_000) {
            if !arch
                .secrets
                .contains(where: { $0.id == index }) {
                return index
            }
        }
        return Int(UInt16.max)
    }
    
    func index(id: Int) -> Int? {
        arch
            .secrets
            .firstIndex {
                $0.id == id
            }
    }
}
