//
//  HomeService.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 14/08/26.
//

import Foundation

final class HomeService {
    
    func fetchCatalog(homeLink: String, page: Int) async throws -> [HomeSection] {
        
        guard let url = endpoint(homeLink: homeLink, page: page, pageSize: 5) else {
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
    
    func fetchCategory(
        homeLink: String,
        page: Int
    ) async throws -> [HomeItem] {

        guard let url = endpoint(
            homeLink: homeLink,
            page: page,
            pageSize: 10
        ) else {
            throw APIError.invalidURL
        }

        print("Calling Category API:", url)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("Category API Status Code:", httpResponse.statusCode)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        let responseModel = try JSONDecoder().decode(
            HomeResponse.self,
            from: data
        )

        let sections = responseModel.data.catalogListItems

        print("CATEGORY PAGE:", page)
        print("CATEGORY SECTIONS:", sections.count)

        for section in sections {
            print("--------------------------------")
            print("CATEGORY SECTION:", section.displayTitle)
            print(
                "CATEGORY SECTION ITEMS:",
                section.catalogListItems?.count ?? 0
            )
        }

        let items = sections.flatMap {
            $0.catalogListItems ?? []
        }

        print("CATEGORY TOTAL ITEMS:", items.count)

        return items
    }
    
    func search(
        query: String,
        page: Int,
        pageSize: Int
    ) async throws -> [HomeItem] {

        guard let url = searchEndpoint(
            query: query,
            page: page,
            pageSize: pageSize
        ) else {
            throw APIError.invalidURL
        }

        print("Calling Search API:", url)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("Search API Status Code:", httpResponse.statusCode)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        let responseModel = try JSONDecoder().decode(
            SearchResponse.self,
            from: data
        )

        print("Search API Decoding Successful")
        print("Search Results:", responseModel.data.items.count)
        print("Search Total Count:", responseModel.data.count)

        return responseModel.data.items
    }
    
    func fetchMovieDetails(catalogId: String, contentId: String) async throws -> MovieDetails {
        
        guard var components = URLComponents(string: APIConfiguration.baseURL + APIEndpoint.mediaitem(catalogID: catalogId, contentID: contentId).path
        ) else {
            throw APIError.invalidURL
        }
        components.queryItems = [ URLQueryItem(name: "auth_token", value: APIConfiguration.authToken),
        
        URLQueryItem(name: "region", value: APIConfiguration.region),
                                
        URLQueryItem(name: "item_language", value: APIConfiguration.itemLanguage)
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        print("Calling MovieDetails API:", url)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Movie Details API Status Code:", httpResponse.statusCode)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let responseModel = try JSONDecoder().decode(MovieDetailsResponse.self, from: data)
        print("Movie details API Decoiding Sucessful")
        
        return responseModel.data
        
    }
    
    func fetchUserDetails(catalogId: String, contentId: String) async throws -> ConsolidatedItemState {
       
        guard let url = URL(string: APIConfiguration.baseURL + APIEndpoint.consolidatedItemStateV3.path) else {
            throw APIError.invalidURL
        }
        
        print("Calling Get all Details API:", url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "auth_token": APIConfiguration.authToken,
            "id": "bbd9abf85937e95ddae993e503289c6c",
            "catalog_id": catalogId,
            "content_definition": "movie",
            "content_id": contentId,
            "md5": "92f5a0ed73891f943aa680bf5eba0308",
            "region": APIConfiguration.region,
            "ts": "1788883603.926777",
            "platform": "ios",
            "category": "action"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("Get All Details API Status Code:", httpResponse.statusCode)


        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode)
        }

            let responseModel = try JSONDecoder().decode(
                ConsolidatedItemStateResponse.self,
                from: data
            )

            print("Get All Details API Decoding Successful")

            return responseModel.data
    }
    
    func fetchRecommended(catalogID: String, genres: [String], page: Int) async throws -> [HomeItem] {
        
        guard var components = URLComponents(string: APIConfiguration.baseURL + APIEndpoint.recomended(catalogId: catalogID).path) else {
            
            throw APIError.invalidURL
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
                name: "genres",
                value: genres.joined(separator: ",")
            ),
            URLQueryItem(
                name: "page",
                value: "\(page)"
            ),
            URLQueryItem(
                name: "page_size",
                value: "10"
            )
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        print("Calling Recomended API:", url)
        
        let response: RecommendedResponse = try await APIClient.shared.request(url)
        
        print("Recomended Items:", response.data.items.count)

        return response.data.items
        
    }
}
private extension HomeService {

    func endpoint(
        homeLink: String,
        page: Int,
        pageSize: Int
    ) -> URL? {

        guard let baseURL = URL(
            string: APIConfiguration.baseURL
        ) else {
            return nil
        }

        let url = baseURL
            .appendingPathComponent("catalog_lists")
            .appendingPathComponent(homeLink)

        guard var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
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
                name: "page_size",
                value: APIConfiguration.npageSize
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
    
    private func searchEndpoint(
        query: String,
        page: Int,
        pageSize: Int
    ) -> URL? {

        guard var components = URLComponents(
            string: "https://stagingapi.dangalplay.com"
        ) else {
            return nil
        }

        components.path = APIEndpoint.search(
            query: query,
            page: page,
            pageSize: pageSize
        ).path

        components.queryItems = [
            URLQueryItem(
                name: "auth_token",
                value: APIConfiguration.searchAuthToken
            ),
            URLQueryItem(
                name: "region",
                value: APIConfiguration.searchRegion
            ),
            URLQueryItem(
                name: "item_language",
                value: APIConfiguration.searchItemLanguage
            ),
            URLQueryItem(
                name: "filters",
                value: APIConfiguration.searchFilters
            ),
            URLQueryItem(
                name: "q",
                value: query
            ),
            URLQueryItem(
                name: "page",
                value: "\(page)"
            ),
            URLQueryItem(
                name: "page_size",
                value: "\(pageSize)"
            )
        ]

        return components.url
    }
    
  
}
