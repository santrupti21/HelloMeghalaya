//
//  ShortsService.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 25/09/26.
//

import Foundation

final class ShortsService {
    
    func fetchShorts(page: Int) async throws -> [ShortItem] {
        
        guard var components = URLComponents(string: APIConfiguration.baseURL + APIEndpoint.shorts.path
        ) else {
            throw APIError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "auth_token", value: APIConfiguration.authToken),
        
            URLQueryItem(name: "item_language", value: APIConfiguration.itemLanguage),
            
            URLQueryItem(name: "pagination", value: APIConfiguration.pagination),
            
            URLQueryItem(name: "page", value: "\(page)"),
            
            URLQueryItem(name: "npage_size", value: APIConfiguration.npageSize)
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        print("Calling Shorts API:", url)
        
        let response: ShortsResponse = try await APIClient.shared.request(url)
        
        print("Shorts received:", response.data.catalogListItems.count)
        
        return response.data.catalogListItems
    }
    
}
