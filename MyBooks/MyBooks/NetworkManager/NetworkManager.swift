import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 