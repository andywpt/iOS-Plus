import Foundation

extension NSSecureCoding {
    func encoded() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }
}
