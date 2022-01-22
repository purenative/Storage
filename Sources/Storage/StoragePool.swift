import Foundation
import OrderedCollections
import Combine
import RealmSwift
import SwiftUI

final public class StoragePool<P: Properties & Hashable>: ObservableObject {
    
    private var storageConfiguration: StorageConfiguration?
    
    private var notificationToken: NotificationToken?
    
    private var storedProperties: [P] = []
    private var enqueuedProperties: [P] = []
    
    @Published
    public private(set) var objects: [P] = []
    
    pulblic var filter: NSPredicate? {
        didSet {
            notifyAboutChanges()
        }
    }
    public var sorting: StoragePoolSorting? {
        didSet {
            notifyAboutChanges()
        }
    }
    
    public init(storageConfiguration: StorageConfiguration? = nil,
                filter: NSPredicate? = nil,
                sorting: StoragePoolSorting? = nil) where P.StoredType: Stored, P.StoredType.PropertiesType == P {

        self.updateSettings(storageConfiguration: storageConfiguration,
                            filter: filter,
                            sorting: sorting)
    }
    
    public init() {
        
    }
    
    deinit {
        removeSubscription()
    }
    
    public func updateSettings(storageConfiguration: StorageConfiguration? = nil,
                               filter: NSPredicate? = nil,
                               sorting: StoragePoolSorting? = nil) where P.StoredType: Stored, P.StoredType.PropertiesType == P {
        
        self.storageConfiguration = storageConfiguration
        
        self.filter = filter
        self.sorting = sorting
        
        self.subscribeUpdates()
    }
    
    public func add(enqueuedProperties: [P]) {
        self.enqueuedProperties += enqueuedProperties
        self.notifyAboutChanges()
    }
    
    public func replace(enqueuedProperties: [P]) {
        self.enqueuedProperties = enqueuedProperties
        self.notifyAboutChanges()
    }
    
    private func getStoredObjects() -> Results<P.StoredType>? where P.StoredType: Stored, P.StoredType.PropertiesType == P {
        guard let realm = try? storageConfiguration?.createRealm() else {
            return nil
        }
        
        var results = realm.objects(P.StoredType.self)
        
        if let filter = filter {
            results = results.filter(filter)
        }

        switch sorting {
        case let .ascendingBy(keyPath):
            results = results.sorted(byKeyPath: keyPath,
                                     ascending: true)

        case let .descendingBy(keyPath):
            results = results.sorted(byKeyPath: keyPath,
                                     ascending: false)

        case .none:
            break
        }
        
        return results
    }
    
    private func removeSubscription() {
        notificationToken?.invalidate()
        notificationToken = nil
    }
    
    private func subscribeUpdates() where P.StoredType: Stored, P.StoredType.PropertiesType == P {
        removeSubscription()
        
        guard let storedObjects = getStoredObjects() else {
            return
        }
        
        notificationToken = storedObjects.observe { [weak self] changeset in
            switch changeset {
            case let .error(error):
                #if DEBUG
                print("ERROR:", error)
                #endif
                self?.updateObjects(withProperties: [])
                
            case let .initial(results), let .update(results, _, _, _):
                let properties: [P] = results.map { $0.asProperties() }
                self?.updateObjects(withProperties: properties)
            }
        }
    }
    
    private func updateObjects(withProperties properties: [P]?) {
        
        self.enqueuedProperties = []
        
        if let properties = properties {
            self.storedProperties = properties
        }
        
        self.notifyAboutChanges()
        
    }
    
    private func notifyAboutChanges() {
        var orderedObjects = OrderedSet(self.storedProperties)
        orderedObjects.append(contentsOf: self.enqueuedProperties)
        let objects = Array(orderedObjects)
        
        DispatchQueue.main.async { [weak self] in
            self?.objects = objects
        }
    }
    
}
