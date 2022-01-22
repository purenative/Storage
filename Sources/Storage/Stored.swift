import RealmSwift

public protocol Stored: Object {
    
    associatedtype PropertiesType = Void
    
    func asProperties() -> PropertiesType
    
}

extension Stored where PropertiesType == Void {
    
    public func asProperties() -> Void {
        ()
    }
    
}
