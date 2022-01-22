import Foundation

public enum StoragePoolSorting {
    
    case ascendingBy(keyPath: String)
    case descendingBy(keyPath: String)
    
    var keyPath: String {
        switch self {
        case let .ascendingBy(keyPath), let .descendingBy(keyPath):
            return keyPath
        }
    }
    
    var ascending: Bool {
        switch self {
        case .ascendingBy:
            return true
            
        default:
            return false
        }
    }
    
}
