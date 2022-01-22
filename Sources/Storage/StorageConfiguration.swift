import Foundation
import RealmSwift

public struct StorageConfiguration {

    let identifier: String
    let deleteStorageIfMigrationNeeded: Bool
    let inMemory: Bool
    let schemaVersion: UInt64
    let storageMigrations: [StorageMigration]
    
    public init(identifier: String,
                deleteStorageIfMigrationNeeded: Bool,
                inMemory: Bool = false,
                schemaVersion: UInt64 = 1,
                storageMigrations: [StorageMigration] = []) {
        
        self.identifier = identifier
        self.deleteStorageIfMigrationNeeded = deleteStorageIfMigrationNeeded
        self.inMemory = inMemory
        self.schemaVersion = schemaVersion
        self.storageMigrations = storageMigrations
        
    }
    
    func createRealmConfiguration() -> Realm.Configuration {
        
        var realmConfiguration = Realm.Configuration.defaultConfiguration
        
        let fileName = identifier + ".realm"
        let fileURL = realmConfiguration.fileURL?.deletingLastPathComponent().appendingPathComponent(fileName)
        realmConfiguration.fileURL = fileURL
        
        realmConfiguration.deleteRealmIfMigrationNeeded = deleteStorageIfMigrationNeeded
        
        realmConfiguration.schemaVersion = schemaVersion
        
        realmConfiguration.migrationBlock = { migration, oldSchemaVersion in
            let storageMigrations = storageMigrations.sorted { $0.schemaVersion < $1.schemaVersion }
            
            for storageMigration in storageMigrations {
                if storageMigration.schemaVersion > oldSchemaVersion {
                    storageMigration.migrationBlock(migration)
                }
            }
        }
        
        return realmConfiguration
        
    }
    
    func createRealm() throws -> Realm {
        
        let realmConfiguration = createRealmConfiguration()
        
        let realm = try Realm(configuration: realmConfiguration)
        
        return realm
    }
    
}

extension StorageConfiguration: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func ==(lhs: StorageConfiguration, rhs: StorageConfiguration) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
}
