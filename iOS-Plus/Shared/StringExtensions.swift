import CryptoKit
import Foundation

extension String {
    var sha256: String {
        let originalData = Data(utf8)
        let hashedData = SHA256.hash(data: originalData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    static func uniqueString() -> Self {
        ProcessInfo.processInfo.globallyUniqueString
    }

    enum CharacterType: CaseIterable {
        case number
        case uppercaseLetter
        case lowercaseLetter
        case all

        var characters: Set<Character> {
            switch self {
            case .number:
                Set("0123456789")
            case .lowercaseLetter:
                Set("abcdefghijklmnopqrstuvwxyz")
            case .uppercaseLetter:
                Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            case .all:
                Self.allCases
                    .filter { $0 != .all }
                    .reduce(into: []) { $0.formUnion($1.characters) }
            }
        }
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func random(length: Int, options: Set<CharacterType> = [.all]) -> Self {
        precondition(length > 0)
        let characters = options.reduce(into: []) { $0.append(contentsOf: $1.characters) }
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < characters.count {
                    result.append(characters[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}
