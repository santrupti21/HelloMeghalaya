//
//  ShortsResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 25/09/26.
//

import Foundation

struct ShortsResponse: Decodable {
    let data: ShortsData
}

struct ShortsData: Decodable {
    let catalogListItems: [ShortItem]
    
    enum CodingKeys: String, CodingKey {
        case catalogListItems = "catalog_list_items"
    }
}

struct ShortItem: Decodable {
    
    let displayTitle: String?
    let contentID: String?
    let catalogID: String?
    
    let description: String?
    let duration: Int?
    let durationString: String?
    
    let videoURL: String?
    let videoURLMP4: String?
    
    let likeCount: Int?
    let shareCount: Int?
    let viewCount: Int?
    let userLikeCount: Int?
    
    let thumbnails: ShortThumbnails?
    
    enum CodingKeys: String, CodingKey {
        
        case displayTitle = "display_title"
        case contentID = "content_id"
        case catalogID = "catalog_id"
        
        case description
        case duration
        case durationString = "duration_string"
        
        case videoURL = "video_url"
        case videoURLMP4 = "video_url_mp4"
        
        case likeCount = "like_count"
        case shareCount = "share_count"
        case viewCount = "view_count"
        case userLikeCount = "user_like_count"

        case thumbnails
    }
}

struct ShortThumbnails: Decodable {

    let small2_3: ShortImage?
    let medium2_3: ShortImage?
    let large2_3: ShortImage?

    enum CodingKeys: String, CodingKey {

        case small2_3 = "small_2_3"
        case medium2_3 = "medium_2_3"
        case large2_3 = "large_2_3"
    }
}

struct ShortImage: Decodable {

    let url: String?
}
