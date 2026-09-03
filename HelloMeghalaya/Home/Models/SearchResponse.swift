//
//  SearchResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 31/08/26.
//

import Foundation

struct SearchResponse: Decodable {
    let data: SearchData
}

struct SearchData: Decodable {
    let items: [HomeItem]
    let count: Int
}
