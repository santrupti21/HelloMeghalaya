//
//  HomeService.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 14/08/26.
//

import Foundation

final class HomeService {
    
    func fetchCatalog(type: CatalogType, page: Int) async throws -> [HomeSection] {
        
        guard let url = endpoint(type: type, page: page) else {
            throw APIError.invalidURL
        }
        
        print("Calling Home API:", url)
        
        let (data,response) = try await URLSession.shared.data(from: url)
        print("Home API Response Received:")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        print("HomeAPI Service Code", httpResponse.statusCode)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let responseModel = try JSONDecoder().decode(HomeResponse.self, from: data)
        
        print("Home API Decoding Successful")
        return responseModel.data.catalogListItems
        
    }
}
    private extension HomeService {
        
        func endpoint(type: CatalogType, page: Int) -> URL? {
            
            guard var components = URLComponents(string: APIConfiguration.baseURL + APIEndpoint.catalog(type: type).path) else {
                return nil
            }
        
            components.queryItems = [
                
                URLQueryItem(
                       name: "auth_token",
                       value: "M4s2FZjgsdCKUyKgjJNE"
                   ),

                   URLQueryItem(
                       name: "region",
                       value: "IN"
                   ),

                   URLQueryItem(
                       name: "item_language",
                       value: ""
                   ),

                   URLQueryItem(
                       name: "pagination",
                       value: "true"
                   ),

                   URLQueryItem(
                       name: "page_size",
                       value: "5"
                   ),

                   URLQueryItem(
                       name: "page",
                       value: "\(page)"
                   ),

                   URLQueryItem(
                       name: "npage_size",
                       value: "10"
                   )
            ]
        
        
        return components.url
    }
    
    
}
