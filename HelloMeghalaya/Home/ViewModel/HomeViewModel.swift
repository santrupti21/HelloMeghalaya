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

    private let catalogTabsService = CatalogTabsService()//tabs
    private let homeService = HomeService()//home section items
    private let imageService: ImageService //imgs
    private let imageCache: ImageCache

    private var selectedTab: CatalogTab?// home, movies etc

    private var currentPage = 0
    private var isLoading = false
    private var hasMoreData = true


    private var allSections: [HomeSection] = []// stores the section received from pagination

    weak var delegate: HomeViewModelDelegate?

    init() {

        let imageCache = ImageCache()

        self.imageCache = imageCache

        self.imageService = ImageService(
            imageCache: imageCache
        )
    }
    
    func fetchHomeScreen() {
        fetchTabs()
    }


    func clearImageCache() {
        imageCache.clear()
    }


    func fetchTabs() {
        //concurrency
        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                let tabs = try await catalogTabsService.fetchTabs()// [CatalogTab]

                delegate?.homeViewModel(
                    self,
                    didUpdateTabs: tabs
                )//I received the tabs. Update the UI.

            } catch {

                delegate?.homeViewModel(
                    self,
                    didFailWith: error
                )
            }
        }
    }


    func changeCatalogTab(_ tab: CatalogTab) {

        selectedTab = tab

        currentPage = 0
        isLoading = false
        hasMoreData = true

        allSections = []

        delegate?.homeViewModel(
            self,
            didUpdateHomeSections: []
        )

        // Clear previous banner

        delegate?.homeViewModel(
            self,
            didUpdateHomeSlider: []
        )

        // Fetch selected tab

        fetchCatalog()
    }


    func fetchCatalog() {

        guard selectedTab != nil else {
            return
        }

        currentPage = 0
        hasMoreData = true
        allSections = []

        loadCatalogPage(
            page: currentPage,
            replaceData: true
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

                print("Requesting page:", page)                // Make sure a tab is selected

                guard let selectedTab else {

                    isLoading = false

                    return
                }
                // Fetch API

                let sections = try await homeService.fetchCatalog(
                    homeLink: selectedTab.homeLink,
                    page: page
                )

                let homeSliderIndex: Int? =
                 replaceData && !sections.isEmpty ? 0 : nil


                if replaceData {

                    let homeSliderItems: [HomeItem]

                    if let homeSliderIndex {

                        homeSliderItems =
                            sections[
                                homeSliderIndex
                            ].catalogListItems ?? []

                    } else {

                        homeSliderItems = []
                    }


                    print(
                        "HOME BANNER ITEMS:",
                        homeSliderItems.count
                    )


                    delegate?.homeViewModel(
                        self,
                        didUpdateHomeSlider:
                            homeSliderItems
                    )
                }

                let tableSections =
                    sections.enumerated().compactMap {
//enumareated = index,value
//compact = transforms items and removes nil results.
                        index,
                        section -> HomeSection? in

                        // Remove banner section

                        guard index != homeSliderIndex else {
                            return nil
                        }
                        // Remove empty sections

                        guard !(
                            section.catalogListItems ?? []
                        ).isEmpty else {

                            return nil
                        }
                        return section
                    }


                if replaceData {

                    // First page
                    allSections = tableSections

                } else {

                    // Next pages
                    allSections = mergeSections(
                        existing: allSections,
                        new: tableSections
                    )
                }
                // Update current page

                currentPage = page

                if sections.isEmpty {

                    hasMoreData = false

                    print("No more home pages.")
                }

                delegate?.homeViewModel(
                    self,
                    didUpdateHomeSections:
                        allSections
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
            print("Pagination skipped: already loading")
            return
        }

        guard hasMoreData else {
            print("Pagination skipped: no more data")
            return
        }

        let nextPage = currentPage + 1

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

            guard let existingIndex =
                    result.firstIndex(
                        where: {
                            $0.displayTitle ==
                            newSection.displayTitle
                        }
                    )
            else {

                result.append(newSection)

                continue
            }

            // Existing section

            let existingSection =
                result[existingIndex]


            let existingItems =
                existingSection.catalogListItems ?? []


            let newItems =
                newSection.catalogListItems ?? []


            let mergedItems =
                existingItems + newItems


            result[existingIndex] =
                HomeSection(
                    displayTitle:
                        existingSection.displayTitle,

                    friendlyID:
                        existingSection.friendlyID,

                    homeLink:
                        existingSection.homeLink,

                    catalogListItems:
                        mergedItems
                )
        }

        return result
    }

    func fetchCategoryPage(
        homeLink: String,
        page: Int
    ) async throws -> [HomeItem] {

        return try await homeService.fetchCategory(
            homeLink: homeLink,
            page: page
        )
    }
 

    func fetchImage(
        from url: URL
    ) async throws -> UIImage {

        try await imageService.fetchImage(
            from: url
        )
    }
}
