//
//  SearchViewModel.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 01/09/26.
//

import Foundation
import Combine
import UIKit

enum SearchState {
    case idle
    case results([HomeItem])
    case noResults
}

protocol searchviewModelDelegate: AnyObject {
    func searchViewModel(
        _ viewModel: SearchViewModel,
        didUpdate state: SearchState
    )
}
@MainActor
final class SearchViewModel {
  
    private let homeService = HomeService()
    
    private let imageCache: ImageCache
    private let imageService: ImageService
    
    private var cancellables = Set<AnyCancellable>()//combine subsricption store
    
    private let searchSubject = PassthroughSubject<String, Never>()
    weak var delegate: searchviewModelDelegate?
    
    private var currentpage = 0
    private let pageSize = 20
    private var isLoading = false
    private var hasMoreResults = true
    private var currentQuery = ""
    private var searchResults: [HomeItem] = []
    
    init() {
        let imageCache = ImageCache()
        self.imageCache = imageCache
        self.imageService = ImageService(imageCache: imageCache)
        setupSearchBinding()
    }
    
    func searchTextChanged(_ text: String) {
        currentQuery = text
        currentpage = 0
        searchResults.removeAll()
        hasMoreResults = true
        
        searchSubject.send(text) //Receive the text from the ViewController and send it into the Combine pipeline.
    }
    
    private func setupSearchBinding() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in //.sink-> receive the values
                guard let self else { return }
                
                guard query.count >= 3 else {
                    self.delegate?.searchViewModel(
                        self,
                        didUpdate: .idle
                    )
                    return
                }
                self.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        
        guard !isLoading else {
            return
        }
        isLoading = true
        
        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let results = try await homeService.search(
                    query: query,
                    page: currentpage,
                    pageSize: pageSize
                )
                
                print("search page:", currentpage)
                print("search results:", results.count)

                if results.isEmpty {
                    hasMoreResults = false
                    
                    if currentpage == 0 {
                        self.delegate?.searchViewModel(
                            self,
                            didUpdate: .noResults
                        )
                    }
                } else {
                    searchResults.append(contentsOf: results)
                    
                    self.delegate?.searchViewModel(
                        self,
                        didUpdate: .results(results)
                    )
                }
                
                isLoading = false

            } catch {
                print("search failed:", error)
            }
        }
    }
    
    func loadNetPage() {
        guard !isLoading else {
            return
        }
        
        guard hasMoreResults else {
            return
        }
        
        currentpage += 1
        performSearch(query: currentQuery)
    }
    func fetchImage(from url: URL) async throws -> UIImage {

          try await imageService.fetchImage(
              from: url
          )
      }
}
