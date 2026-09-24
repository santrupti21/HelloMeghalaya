import Foundation

struct Episode: Decodable {

    let title: String?
    let contentID: String?
    let catalogID: String?
    let description: String?
    let language: String?
    let durationString: String?
    let itemCaption: String?
    let sequenceNo: Int?
    let thumbnails: EpisodeThumbnails?

    enum CodingKeys: String, CodingKey {
        case title
        case contentID = "content_id"
        case catalogID = "catalog_id"
        case description
        case language
        case durationString = "duration_string"
        case itemCaption = "item_caption"
        case sequenceNo = "swquence_no"
        case thumbnails
    }
}

struct EpisodeThumbnails: Decodable {

    let xlImage16x9: EpisodeThumbnail?

    enum CodingKeys: String, CodingKey {
        case xlImage16x9 = "xl_image_16_9"
    }
}

struct EpisodeThumbnail: Decodable {

    let url: String?
}

struct EpisodeResponse: Decodable {
    let data: EpisodeData
}

struct EpisodeData: Decodable {
    let items: [Episode]
}
