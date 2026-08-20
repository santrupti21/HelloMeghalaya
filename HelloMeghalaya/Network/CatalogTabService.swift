//
//  CatalogTabService.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 12/08/26.
//



import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}


enum APIConfiguration {

    static let baseURL =
        "https://preprodapi.hellomeghalaya.in"
}

enum APIEndpoint {

    case catalogTabs
    case home

    var path: String {

        switch self {

        case .catalogTabs:
            return "/catalog_lists/catalog-tabs.gzip"
            
        case .home:
            return "/catalog_lists/home.gzip"
            
        }
    }
}

final class CatalogTabsService {

    func fetchTabs() async throws -> [CatalogTab] {

        guard let url = endpoint else {
            throw APIError.invalidURL
        }

        print("Calling API:", url)

        let (data, response) = try await URLSession.shared.data(from: url)

        print("API Response Received")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("Status Code:", httpResponse.statusCode)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let responseModel = try JSONDecoder().decode( CatalogTabsResponse.self, from: data)

        print("Decoding Successful")

        return responseModel.data.catalogListItems
    }
}

private extension CatalogTabsService {

    var endpoint: URL? {

        guard var components = URLComponents(
            string:
                APIConfiguration.baseURL
                + APIEndpoint.catalogTabs.path
        ) else {
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
                name: "page",
                value: "0"
            ),

            URLQueryItem(
                name: "npage_size",
                value: "10"
            )
        ]

        return components.url
    }
}

