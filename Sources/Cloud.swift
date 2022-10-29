import Archivable

extension Cloud where Output == Archive {    
    public func secret() async throws -> Int {
        var model = await model
        guard model.available else { throw SecretsError.full }
        let id = model.id
        model
            .secrets
            .append(
                .new
                    .with(id: id)
                    .with(name: "Untitled"))
        await update(model: model)
        return id
    }
    
    public func delete(id: Int) async {
        var model = await model
        guard let index = model.index(id: id) else { return }
        model
            .secrets
            .remove(at: index)
        await update(model: model)
    }
    
    public func update(id: Int, name: String) async {
        var model = await model
        guard
            let index = model.index(id: id),
            name != model.secrets[index].name
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(name: name)
            }
        await update(model: model)
    }
    
    public func update(id: Int, payload: String) async {
        var model = await model
        guard
            let index = model.index(id: id),
            payload != model.secrets[index].payload
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(payload: payload)
            }
        await update(model: model)
    }
    
    public func update(id: Int, name: String, payload: String) async {
        var model = await model
        guard
            let index = model.index(id: id),
            name != model.secrets[index].name || payload != model.secrets[index].payload
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0
                    .with(name: name)
                    .with(payload: payload)
            }
        await update(model: model)
    }
    
    public func update(id: Int, favourite: Bool) async {
        var model = await model
        guard
            let index = model.index(id: id),
            favourite != model.secrets[index].favourite
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(favourite: favourite)
            }
        await update(model: model)
    }
    
    public func add(id: Int, tag: Tag) async {
        var model = await model
        guard
            let index = model.index(id: id),
            !model.secrets[index].tags.contains(tag)
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .inserting(tag))
            }
        await update(model: model)
    }
    
    public func remove(id: Int, tag: Tag) async {
        var model = await model
        guard
            let index = model.index(id: id),
            model.secrets[index].tags.contains(tag)
        else { return }
        model
            .secrets
            .mutate(index: index) {
                $0.with(tags: $0
                            .tags
                            .removing(tag))
            }
        await update(model: model)
    }
    
    public func add(purchase: Purchase) async {
        var model = await model
        model.capacity += purchase.value
        await update(model: model)
    }
    
    public func remove(purchase: Purchase) async {
        var model = await model
        model.capacity -= purchase.value
        model.capacity = Swift.max(model.capacity, 1)
        await update(model: model)
    }
}
