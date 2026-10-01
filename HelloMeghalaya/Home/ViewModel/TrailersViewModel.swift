//
//  TrailersViewModel.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 28/09/26.
//

import Foundation
import UIKit

@MainActor
final class TrailersViewModel {
    
    private let homeService = HomeService()
    
    private let imageCache: ImageCache
    private let imageService: ImageService
    
    private(set) var trailers: [HomeItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    init() {
        let cache = ImageCache()
        self.imageCache = cache
        self.imageService = ImageService(imageCache: cache)
    }
    
    func fetchTrailers() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            trailers = try await homeService.fetchTrailers()
            print("Trailers loaded:", trailers.count)
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to fetch trailers:", error)
        }
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        try await imageService.fetchImage(from: url)
    }
}
