//
//  ConsolidatedItemStateResponse.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 17/09/26.
//

import Foundation

struct ConsolidatedItemStateResponse: Decodable {
    let data: ConsolidatedItemState
}

struct ConsolidatedItemState: Decodable {
    let isSubscribed: Bool?
    let drmProtected: String?
    let playURL: PlayURL?
    let adaptiveURL: String?
    let userLikeCount: Int?
    let playlists: [Playlist]?

    enum CodingKeys: String, CodingKey {
        case isSubscribed = "is_subscribed"
        case drmProtected = "drm_protected"
        case playURL = "play_url"
        case adaptiveURL = "adaptive_url"
        case userLikeCount = "user_like_count"
        case playlists
    }
}

struct Playlist: Decodable {
    let name: String?
    let pos: String?
    let playlistID: String?
    let listitemID: String?

    enum CodingKeys: String, CodingKey {
        case name
        case pos
        case playlistID = "playlist_id"
        case listitemID = "listitem_id"
    }
}
