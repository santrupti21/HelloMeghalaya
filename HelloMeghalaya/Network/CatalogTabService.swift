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
        Bundle.main.object(
            forInfoDictionaryKey: "APIBaseURL"
        ) as? String ?? ""

    static let authToken =
        Bundle.main.object(
            forInfoDictionaryKey: "APIAuthtoken"
        ) as? String ?? ""

    static let region =
        Bundle.main.object(
            forInfoDictionaryKey: "APIRegion"
        ) as? String ?? ""

    static let itemLanguage =
        Bundle.main.object(
            forInfoDictionaryKey: "APIItemLanguage"
        ) as? String ?? ""

    static let pagination =
        Bundle.main.object(
            forInfoDictionaryKey: "APIPagination"
        ) as? String ?? ""

    static let npageSize =
        Bundle.main.object(
            forInfoDictionaryKey: "APINPageSize"
        ) as? String ?? ""

    static let searchBaseURL =
        Bundle.main.object(
            forInfoDictionaryKey: "SearchBaseURL"
        ) as? String ?? ""

    static let searchAuthToken =
        Bundle.main.object(
            forInfoDictionaryKey: "SearchAPIAuthtoken"
        ) as? String ?? ""

    static let searchRegion =
        Bundle.main.object(
            forInfoDictionaryKey: "SearchAPIRegion"
        ) as? String ?? ""

    static let searchItemLanguage =
        Bundle.main.object(
            forInfoDictionaryKey: "SearchAPIItemLanguage"
        ) as? String ?? ""

    static let searchFilters =
        Bundle.main.object(
            forInfoDictionaryKey: "SearchAPIFilters"
        ) as? String ?? ""
}


enum APIEndpoint {

    case catalogTabs
    case catalog(homeLink: String)
    case search(query: String, page: Int, pageSize: Int)

    var path: String {

        switch self {

        case .catalogTabs:
            return "/catalog_lists/catalog-tabs.gzip"

        case .catalog(let homeLink):
            return homeLink
            
        case .search:
            return "/search.gzip"
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
                value: APIConfiguration.authToken
            ),
            URLQueryItem(
                name: "region",
                value: APIConfiguration.region
            ),
            URLQueryItem(
                name: "item_language",
                value: APIConfiguration.itemLanguage
            ),
            URLQueryItem(
                name: "pagination",
                value: APIConfiguration.pagination
            ),
            URLQueryItem(
                name: "page",
                value: "0"
            ),
            URLQueryItem(
                name: "npage_size",
                value: APIConfiguration.npageSize
            )
        ]
        return components.url
    }
}

