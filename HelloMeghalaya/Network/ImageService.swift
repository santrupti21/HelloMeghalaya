//
//  ImageService.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 20/08/26.
//

import UIKit


final class ImageService {
    
    //di-> img service depends on imgcache
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache) {
        self.imageCache = imageCache
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        
        if let cachedImage = imageCache.image(for: url){
            return cachedImage
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard let image = UIImage(data: data) else {
            throw APIError.invalidResponse
        }
        
        imageCache.setImage(image, for: url)
        
        return image
    }
}
