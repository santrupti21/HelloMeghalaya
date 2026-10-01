//
//  TrailersResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 28/09/26.
//

import Foundation

struct TrailersResponse: Decodable {
    let data: TrailersData

}

struct TrailersData: Decodable {
    let catalogListItems: [HomeItem]
    
    enum CodingKeys: String, CodingKey {
        case catalogListItems = "catalog_list_items"
    }
}
