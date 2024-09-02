import Foundation

protocol HttpClient {
    func performRequest(_ request: URLRequest) async throws -> (Int, Data)
}
