//
//  CatalogTabResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 12/08/26.
//


import Foundation

struct CatalogTabsResponse: Decodable {

    let data: CatalogTabsData
}

struct CatalogTabsData: Decodable {

    let catalogListItems: [CatalogTab]

    enum CodingKeys: String, CodingKey {

        case catalogListItems = "catalog_list_items"
    }
}

struct CatalogTab: Decodable {
    let displayTitle: String
    let friendlyID: String
    let homeLink: String
    let listID: String

    enum CodingKeys: String, CodingKey {
        case displayTitle = "display_title"
        case friendlyID = "friendly_id"
        case homeLink = "home_link"
        case listID = "list_id"
    }
}
