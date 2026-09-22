//
//  APIClient.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 18/09/26.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    func request<T: Decodable>(_ url: URL) async throws -> T {
        print("Calling API:", url)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        print("Status Code:", httpResponse.statusCode)
        
        guard(200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
