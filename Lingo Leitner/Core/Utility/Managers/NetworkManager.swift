import Foundation
import Alamofire
import SwiftyJSON

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var message: String {
        switch self {
        case .invalidURL: return "error_invalid_url".localized
        case .noData: return "error_no_data".localized
        case .decodingError: return "error_decoding".localized
        case .serverError(let message): return message
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.yourdomain.com/v1"
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        let url = "\(baseURL)/\(endpoint)"
        
        let request = AF.request(
            url,
            method: method,
            parameters: parameters,
            headers: headers
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            request.responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.serverError(error.localizedDescription))
                }
            }
        }
    }
} 