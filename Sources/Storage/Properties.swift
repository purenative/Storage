import Foundation

public protocol Properties: Decodable {
    
    associatedtype StoredType = Void
    
    func asStored() -> StoredType
    
}

extension Properties where StoredType == Void {
    
    public func asStored() -> Void {
        ()
    }
    
}

