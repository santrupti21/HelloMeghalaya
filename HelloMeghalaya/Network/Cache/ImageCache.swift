//
//  ImageCache.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 21/08/26.
//

import UIKit

final class ImageCache {
    
    private let cache = NSCache<NSURL, UIImage>()
    
    init() {
        cache.countLimit = 50
        cache.totalCostLimit = 50 * 1024 * 1024 //50mb == 52,428,800 bytes
    }
    
    //get-> Read
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    //set->Write
    func setImage(_ image: UIImage, for url: URL) {
        
        let imageCost = cost(for: image)
        cache.setObject(image, forKey: url as NSURL, cost: imageCost)
    }
    
    //claear()
    func clear() {
        cache.removeAllObjects()
    }
    
    private func cost(for image: UIImage) -> Int {
            Int(image.size.width * image.scale)
                * Int(image.size.height * image.scale)
                * 4
        }

}
