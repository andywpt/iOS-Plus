import Foundation

struct MockData {
    let id: Int
    let imageUrl: URL
}

actor MockRepository {
    
    func imageUrl(id: Int, width: Int = 560, height: Int = 560) -> URL {
        var validId = id % 1000
        validId = validId < 0 ? validId + 1000 : validId
        return URL(string: "https://picsum.photos/id/\(validId)/\(width)/\(height)")!
    }
}
