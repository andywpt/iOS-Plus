import Foundation

extension URLSession: HttpClient {
    //https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
    func performRequest(_ request: URLRequest) async throws -> (Int, Data) {
        let (data, response) = try await data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
        return (statusCode,data)
    }

}
