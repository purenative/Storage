import Foundation
import RealmSwift

public class Storage {
    
    private let storageConfiguration: StorageConfiguration
    
    private var realm: Realm {
        try! storageConfiguration.createRealm()
    }
    
    init(storageConfiguration: StorageConfiguration) {
        self.storageConfiguration = storageConfiguration
    }
    
}

extension Storage {
    
    // MARK: Counting
    
    public func countOf<O: Object>(type: O.Type,
                                   filter: NSPredicate? = nil) -> Int {
        
        if let filter = filter {
            return realm.objects(O.self).filter(filter).count
        } else {
            return realm.objects(O.self).count
        }
        
    }
    
    // MARK: Requesting
    
    public func objectsOf<O: Object>(type: O.Type,
                                     filter: NSPredicate? = nil) -> Results<O> {
        
        if let filter = filter {
            return realm.objects(O.self).filter(filter)
        } else {
            return realm.objects(O.self)
        }
        
    }
    
    // MARK: Creation/Insertion/Deletion
    
    public func store<O: Object, C: Collection>(collection: C,
                                                replacingAll: Bool = false) where C.Element == O {
        
        try! realm.write {
            if replacingAll {
                let allObjects = realm.objects(O.self)
                realm.delete(allObjects)
            }
            
            if O.primaryKey() == nil {
                realm.add(collection)
            } else {
                realm.add(collection,
                          update: .all)
            }
        }
        
    }
    
    public func deleteObject<O: Object, KeyType>(ofType type: O.Type, withPrimaryKey primaryKey: KeyType) {
        if let object = realm.object(ofType: type, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(object)
            }
        }
    }
    
    public func deleteAll<O: Object>(ofType type: O.Type) {
        
        try! realm.write {
            let allObjects = realm.objects(type)
            realm.delete(allObjects)
        }
        
    }
    
}
