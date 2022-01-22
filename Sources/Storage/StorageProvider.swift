final public class StorageProvider {
    
    private var storages: [String: Storage]
    
    public init() {
        self.storages = [:]
    }
    
    public func getStorage(with storageConfiguration: StorageConfiguration) -> Storage {
        if let storage = self.storages[storageConfiguration.identifier] {
            return storage
        } else {
            let newStorage = Storage(storageConfiguration: storageConfiguration)
            self.storages[storageConfiguration.identifier] = newStorage
            return newStorage
        }
    }
    
}
