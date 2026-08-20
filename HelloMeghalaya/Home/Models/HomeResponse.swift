//
//  HomeResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 14/08/26.
//

import Foundation

struct HomeResponse: Decodable {
    
    let data: HomeData
}

struct HomeData: Decodable {
    let catalogListItems: [HomeSection]
    
    enum CodingKeys: String, CodingKey {
        case catalogListItems = "catalog_list_items"
    }
}

struct HomeSection: Decodable {
    
    let displayTitle: String
    let catalogListItems: [HomeItem]?
    let catalogObject: CatalogObject?
    
    enum CodingKeys: String, CodingKey {
        
        case displayTitle = "display_title"
        case catalogListItems = "catalog_list_items"
        case catalogObject = "catalog_object"
    }
    
}

struct HomeItem: Decodable {
    
    let displayTitle: String
    let contentID: String
    let thumbnails: HomeThumbnails
    
    enum CodingKeys: String, CodingKey {
        case displayTitle = "display_title"
        case contentID = "content_id"
        case thumbnails
    }
    
}

struct CatalogObject: Decodable {
    
    let layoutType: String?
    
    enum CodingKeys: String, CodingKey {
        case layoutType = "layout_type"
    }
}

struct HomeThumbnails: Decodable {
    
    let small16_9: HomeImage?
    let medium16_9: HomeImage?
    let large16_9: HomeImage?
    
    let small2_3: HomeImage?
    let medium2_3: HomeImage?
    let large2_3: HomeImage?
    
    enum CodingKeys: String, CodingKey {
        case small16_9 = "small_16_9"
        case medium16_9 = "medium_16_9"
        case large16_9 = "large_16_9"
        
        case small2_3 = "small_2_3"
        case medium2_3 = "medium_2_3"
        case large2_3 = "large_2_3"
        
    }
    
}

struct HomeImage: Decodable {
    let url: String
}


