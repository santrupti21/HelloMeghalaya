//
//  MovieDetailsResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 09/09/26.
//

import Foundation

struct MovieDetailsResponse: Decodable {
    let data: MovieDetails
}

struct MovieDetails: Decodable {
    let title: String?
    let description: String?
    let genres: [String]?
    let itemCaption: String? // genere + language
    let thumbnails: MovieThumbnails?
    let preview: MoviePreview?
    let shareURL: String?
    let cbfcRating: String?
    let accessControl: AccessControl?
    
    let contentType: String?
    let playURL: PlayURL?
    
    let episodeCount: Int?
    let subcategoryFlag: String?
    let subcategories: [Subcategory]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case genres
        case itemCaption = "item_caption"
        case thumbnails
        case preview
        case shareURL = "share_url"
        case cbfcRating = "cbfc_rating"
        case accessControl = "access_control"
        
        case contentType = "content_type"
        case playURL = "play_url"
        
        case episodeCount = "episode_count"
        case subcategoryFlag = "subcategory_flag"
        case subcategories
    }
    
}

struct Subcategory: Decodable {
    let title: String?
    let contentID: String?
    let catalogID: String?
    let language: String?
    let episodeFlag: String?
    let episodeCount: Int?
    let sequenceNo: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case contentID = "content_id"
        case catalogID = "catalog_id"
        case language
        case episodeFlag = "episode_flag"
        case episodeCount = "episode_count"
        case sequenceNo = "sequence_no"
    }
}

struct MovieThumbnails: Decodable {
    let large16_9: ImageURL?
    let large2_3: ImageURL?
    
    enum CodingKeys: String, CodingKey {
        case large16_9 = "large_16_9"
        case large2_3 = "large_2_3"
    }
}

struct ImageURL: Decodable {
    let url: String?
}

struct MoviePreview: Decodable {
    let previewAvailable: Bool?
    let previewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case previewAvailable = "preview_available"
        case previewURL = "preview_url"
    }
}

struct PlayURL: Decodable {
    let saranyu: PlayURLValue?
}

struct PlayURLValue: Decodable {
    let url: String
}

struct AccessControl: Decodable {
    let isFree: Bool?
    let premiumTag: Bool?
    let loginRequired: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isFree = "is_free"
        case premiumTag = "premium_tag"
        case loginRequired = "login_required"
        
    }
}
