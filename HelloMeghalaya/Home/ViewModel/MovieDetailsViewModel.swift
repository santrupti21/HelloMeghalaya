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
    
    private(set) var movieDetails: MovieDetails?
    private(set) var userDetails: ConsolidatedItemState?//viedos watchnow
    private(set) var recommendedItems: [HomeItem] = []
    
    init(catalogId: String, contentId: String) {
        self.catalogId = catalogId
        self.contentId = contentId
        
        let imageCache = ImageCache()
        self.imageService = ImageService(imageCache: imageCache)
    }
    
    func fetchMovieDetails() async throws {
        let details = try await homeService.fetchMovieDetails(catalogId: catalogId, contentId: contentId)
        movieDetails = details
        
        await fetchRecommended(catalogID: catalogId, genres: details.genres ?? [])
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
            
            let items = try await homeService.fetchRecommended(catalogID: catalogID, genres: genres, page: 0)
            
            recommendedItems = items
            
            delegate?.didUpdateRecommendedItems()
            
            print("Recomended items:", items.count)
        } catch {
            print("Recomended API error:", error)
        }
    }
    

    
    func fetchImage(from url: URL) async throws -> UIImage {
        try await imageService.fetchImage(from: url)
    }
    
    
}
