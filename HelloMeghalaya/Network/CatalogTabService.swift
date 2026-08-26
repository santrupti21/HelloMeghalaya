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
    
    static let region = Bundle.main.object(forInfoDictionaryKey: "APIRegion") as? String ?? ""
}

enum CatalogType {
    case home
    case movies
    case music
    case infotainment
    case hmOriginals
    case liveEvents
    
    init?(friendlyID: String) {
        switch friendlyID.lowercased() {
        case "home-tab":
            self = .home

        case "movies-tab":
            self = .movies
            
        case "music-tab":
            self = .music
            
        case "creators-tab":
            self = .infotainment
            
        case "hm-originals-tab":
            self = .hmOriginals

        case "live-events-tab":
            self = .liveEvents
            
        default:
            return nil
            
        }
    }
}

enum APIEndpoint {

    case catalogTabs
    case catalog(type: CatalogType)

    var path: String {

        switch self {

        case .catalogTabs:
            return "/catalog_lists/catalog-tabs.gzip"
            
        case .catalog(let type):
            
            switch type {
            case .home:
                return "/catalog_lists/home.gzip"
                
            case .movies:
                return "/catalog_lists/movies.gzip"
                
            case .music:
                return "/catalog_lists/music.gzip"

            case .infotainment:
                return "/catalog_lists/creators.gzip"
                
            case .hmOriginals:
                return "/catalog_lists/hm-originals.gzip"

            case .liveEvents:
                return "/catalog_lists/live-events.gzip"
                
            }
            
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
                value: APIConfiguration.region
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

