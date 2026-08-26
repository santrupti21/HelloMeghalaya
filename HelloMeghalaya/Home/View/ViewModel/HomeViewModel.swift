import Foundation
import UIKit

@MainActor
protocol HomeViewModelDelegate: AnyObject {

    func homeViewModel(
        _ viewModel: HomeViewModel,
        didUpdateTabs tabs: [CatalogTab]
    )

    func homeViewModel(
        _ viewModel: HomeViewModel,
        didUpdateHomeSections sections: [HomeSection]
    )

    func homeViewModel(
        _ viewModel: HomeViewModel,
        didUpdateHomeSlider items: [HomeItem]
    )

    func homeViewModel(
        _ viewModel: HomeViewModel,
        didFailWith error: Error
    )
}

@MainActor
final class HomeViewModel {

    private let catalogTabsService = CatalogTabsService()
    private let homeService = HomeService()

    private let imageService: ImageService
    private let imageCache: ImageCache
    
    private var catalogType: CatalogType
    
    private var sliderTitle: String {
        switch catalogType {
        case .home:
            return "Home Slider"
            
        case .movies:
            return "Movies Slider"
            
        case .music:
             return "Music Slider"

         case .infotainment:
             return "Creators Slider"
            
        case .hmOriginals:
               return "HM Originals banner"

        case .liveEvents:
               return "Live Events"
        }
    }

    private var currentPage = 0
    private var isLoading = false
    private var hasMoreData = true
    private var allSections: [HomeSection] = []


    weak var delegate: HomeViewModelDelegate?


    init(catalogType: CatalogType = .home) {
        
        self.catalogType = catalogType

        let imageCache = ImageCache()

        self.imageCache = imageCache
        self.imageService = ImageService(
            imageCache: imageCache
        )
    }

    func clearImageCache() {

        imageCache.clear()
    }


    func fetchTabs() {

        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                let tabs = try await catalogTabsService.fetchTabs()

                delegate?.homeViewModel(
                    self,
                    didUpdateTabs: tabs
                )

            } catch {

                delegate?.homeViewModel(
                    self,
                    didFailWith: error
                )
            }
        }
    }
    
    func changeCatalogType(to type: CatalogType) {
        catalogType = type

        currentPage = 0
        isLoading = false
        hasMoreData = true
        allSections = []
        delegate?.homeViewModel(
               self,
               didUpdateHomeSections: []
           )

           delegate?.homeViewModel(
               self,
               didUpdateHomeSlider: []
           )

           fetchCatalog()       
    }


    func fetchCatalog() {
        
        currentPage = 0
        hasMoreData = true
        allSections = []

        loadCatalogPage(
            page: currentPage,replaceData: true
        )
    }


    private func loadCatalogPage(
        page: Int,
        replaceData: Bool
    ) {

        guard !isLoading else {
            return
        }

        guard hasMoreData else {
            return
        }

        isLoading = true

        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                print("Requesting page:", page)
                
                let sections = try await homeService.fetchCatalog(
                    type: catalogType,
                    page: page
                )
                
                print("PAGE \(page) RAW SECTIONS:", sections.count)
                
                print("")
                print("========== \(catalogType) ==========")

                for section in sections {
                    print("------------------------------------")
                    print("SECTION:", section.displayTitle)

                    let layoutType =
                        section.catalogListItems?.first?.catalogObject?.layoutType

                    print("LAYOUT TYPE:", layoutType ?? "nil")
                    print("ITEM COUNT:", section.catalogListItems?.count ?? 0)
                }

                if replaceData {

                    if let homeSliderSection = sections.first(
                        where: {
                            $0.displayTitle == sliderTitle
                        }
                    ) {

                        let homeSliderItems =
                            homeSliderSection.catalogListItems ?? []

                        delegate?.homeViewModel(
                            self,
                            didUpdateHomeSlider: homeSliderItems
                        )
                    }
                }

                let tableSections = sections.filter {

                    $0.displayTitle != sliderTitle &&
                    !($0.catalogListItems ?? []).isEmpty
                }


                if replaceData {
                    allSections = tableSections

                } else {

                    allSections = mergeSections(
                        existing: allSections,
                        new: tableSections
                    )
                }

                currentPage = page

                if tableSections.isEmpty {

                    hasMoreData = false
                }

                delegate?.homeViewModel(
                    self,
                    didUpdateHomeSections: allSections
                )

                isLoading = false

            } catch {
                isLoading = false

                delegate?.homeViewModel(
                    self,
                    didFailWith: error
                )
            }
        }
    }

    func loadNextPage() {

        guard !isLoading else {
            return
        }

        guard hasMoreData else {
            return
        }

        let nextPage = currentPage + 1
        
        print("Loading page:", nextPage)

        loadCatalogPage(
            page: nextPage,
            replaceData: false
        )
    }

    private func mergeSections(
        existing: [HomeSection],
        new: [HomeSection]
    ) -> [HomeSection] {

        var result = existing

        for newSection in new {


            guard let existingIndex = result.firstIndex(
                where: {
                    $0.displayTitle ==
                    newSection.displayTitle
                }
            ) else {

                result.append(newSection)

                continue
            }

            let existingSection =
                result[existingIndex]
            
            let existingItems =
                existingSection.catalogListItems ?? []
            
            let newItems =
                newSection.catalogListItems ?? []

            let mergedItems =
                existingItems + newItems

            result[existingIndex] = HomeSection(
                displayTitle: existingSection.displayTitle,
                catalogListItems: mergedItems
            )        }

        return result
    }


    func fetchImage(
        from url: URL
    ) async throws -> UIImage {

        try await imageService.fetchImage(
            from: url
        )
    }

    func fetchHomeScreen() {

        fetchTabs()

        fetchCatalog()
    }
}
