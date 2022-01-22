import RealmSwift

public struct StorageMigration {
    
    public typealias StorageMigrationBlock = (Migration) -> Void
    
    let schemaVersion: UInt64
    let migrationBlock: StorageMigrationBlock
    
    public init(schemaVersion: UInt64,
                migrationBlock: @escaping StorageMigrationBlock) {
        
        self.schemaVersion = schemaVersion
        self.migrationBlock = migrationBlock
    }
    
}
