import Foundation

extension Data {
    func decoded<T>(as _: T.Type) throws -> T where T: Decodable {
        try JSONDecoder().decode(T.self, from: self)
    }

    func decoded<T>(as _: T.Type) throws -> T where T: NSObject & NSSecureCoding {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: self)!
    }
}
