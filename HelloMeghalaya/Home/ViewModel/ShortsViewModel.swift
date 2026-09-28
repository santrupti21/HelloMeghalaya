//
//  ShortsViewModel.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 25/09/26.
//

import Foundation

@MainActor
final class ShortsViewModel {
    
    private let shortsService = ShortsService()
    
    private(set) var shorts: [ShortItem] = []
    
    private(set) var isLoading = false
    
    private var currentPage = 0
    
    func fetchShorts() async {
        
        guard !isLoading else {
            return
        }
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            let items = try await shortsService.fetchShorts(page: currentPage)
            shorts = items
        } catch {
            print("Shorts API Error:", error)
        }
    }
}
