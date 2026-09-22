//
//  RecomendedResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 18/09/26.
//

import Foundation

struct RecommendedResponse: Decodable {
    let data: RecommendedData
}

struct RecommendedData: Decodable {
    let items: [HomeItem]
}
