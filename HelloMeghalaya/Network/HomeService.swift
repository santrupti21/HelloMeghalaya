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
                name: "page_size",
                value: "\(pageSize)"
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
