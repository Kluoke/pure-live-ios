import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL, headers: [String: String] = [:]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw APIError.invalidResponse
        }
        return data
    }

    func json(from url: URL, headers: [String: String] = [:]) async throws -> Any {
        try JSONSerialization.jsonObject(with: data(from: url, headers: headers))
    }
}

enum APIError: Error {
    case invalidResponse
}
