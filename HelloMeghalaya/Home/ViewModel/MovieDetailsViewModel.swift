//
//  MovieDetailsViewModel.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 09/09/26.
//
 
import UIKit

protocol MovieDetailsViewModelDelegate: AnyObject {
    func didUpdateRecommendedItems()
}

@MainActor
final class MovieDetailsViewModel {
    
    weak var delegate: MovieDetailsViewModelDelegate?
    
    private let homeService = HomeService()
    private let imageService: ImageService
    
    private let catalogId: String
    private let contentId: String
    private let isEpisode: Bool
    private(set) var episode: Episode?
    private(set) var movieDetails: MovieDetails?
    private(set) var parentShowDetails: MovieDetails?
    private(set) var detailsType: DetailsType = .movie
    private(set) var userDetails: ConsolidatedItemState?//viedos watchnow
    private(set) var recommendedItems: [HomeItem] = []
    private(set) var episodes: [Episode] = []
    private(set) var selectedLanguageContentID: String?
    
    init(catalogId: String, contentId: String, isEpisode: Bool = false, episode: Episode? = nil, parentShowDetails: MovieDetails? = nil,   selectedLanguageContentID: String? = nil) {
        self.catalogId = catalogId
        self.contentId = contentId
        self.isEpisode = isEpisode
        self.episode = episode
        self.parentShowDetails = parentShowDetails
        self.selectedLanguageContentID = selectedLanguageContentID
        
        let imageCache = ImageCache()
        self.imageService = ImageService(imageCache: imageCache)
    }
    
    func fetchMovieDetails() async throws {
        
        if isEpisode {
            detailsType = .episode
            return
        }
        
        let details = try await homeService.fetchMovieDetails(catalogId: catalogId, contentId: contentId)
        movieDetails = details
        
        if isEpisode {
            detailsType = .episode
        }
       else if (details.episodeCount ?? 0) > 0 {
            detailsType = .show
        } else {
            detailsType = .movie
        }
        
        print("===== DETAILS =====")
           print("Title:", details.title ?? "No title")
           print("Episode Count:", details.episodeCount ?? 0)
           print("Subcategory Flag:", details.subcategoryFlag ?? "No flag")

           print("===== SUBCATEGORIES =====")

           for subcategory in details.subcategories ?? [] {
               print("Title:", subcategory.title ?? "No title")
               print("Content ID:", subcategory.contentID ?? "No ID")
               print("Catalog ID:", subcategory.catalogID ?? "No ID")
               print("Language:", subcategory.language ?? "No language")
               print("Episode Flag:", subcategory.episodeFlag ?? "No flag")
               print("Episode Count:", subcategory.episodeCount ?? 0)
               print("Sequence:", subcategory.sequenceNo ?? 0)
               print("----------------------")
           }
        
        if detailsType == .movie {
            await fetchRecommended(catalogID: catalogId, genres: details.genres ?? [])}
    }
    
    func fetchEpisodes(subcategoryID: String) async {
        selectedLanguageContentID = subcategoryID

        do {
            episodes = try await homeService.fetchEpisodes(
                subcategoryID: subcategoryID
            )

            print("Episodes loaded:", episodes.count)
        } catch {
            print("Episodes API Failed:", error)
        }
    }
    
    func fetchUserDetails() async throws {
        let details = try await homeService.fetchUserDetails(catalogId: catalogId, contentId: contentId)
        
       userDetails = details
        
        print("Is Subscribed:", details.isSubscribed ?? false)
            print("Adaptive URL:", details.adaptiveURL ?? "No URL")
            print("Like Count:", details.userLikeCount ?? 0)
    }
    
    func fetchRecommended(catalogID: String, genres: [String]) async {

        do {
            print("Recommended catalog ID:", catalogID)
            print("Recommended genres:", genres)

            let items = try await homeService.fetchRecommended(
                catalogID: catalogID,
                genres: genres,
                page: 0
            )

            recommendedItems = items.filter {
                $0.contentID != contentId
            }

            delegate?.didUpdateRecommendedItems()

            print("Recommended items:", recommendedItems.count)

        } catch {
            print("Recommended API error:", error)
        }
    }
    

    
    func fetchImage(from url: URL) async throws -> UIImage {
        try await imageService.fetchImage(from: url)
    }
    
    
}
