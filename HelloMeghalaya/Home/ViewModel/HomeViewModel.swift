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
    
    func clearImageCache() {
        imageCache.clear()
    }

    weak var delegate: HomeViewModelDelegate?
    
    init() {
        let imageCache = ImageCache()
        self.imageCache = imageCache
        self.imageService = ImageService(imageCache: imageCache)
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

    func fetchHome() {

        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                let sections = try await homeService.fetchHome()
                
                for section in sections {
                                print("SECTION:", section.displayTitle)
                                print("LAYOUT:", section.catalogObject?.layoutType ?? "")
                            }

                let tableSections = sections.filter {
                    $0.displayTitle != "Home Slider" &&
                    !($0.catalogListItems ?? []).isEmpty
                }

                guard let homeSliderSection = sections.first(
                    where: {
                        $0.displayTitle == "Home Slider"
                    }
                ) else {
                    return
                }

                let homeSliderItems =
                    homeSliderSection.catalogListItems ?? []

                delegate?.homeViewModel(
                    self,
                    didUpdateHomeSlider: homeSliderItems
                )

                delegate?.homeViewModel(
                    self,
                    didUpdateHomeSections: tableSections
                )

            } catch {

                delegate?.homeViewModel(
                    self,
                    didFailWith: error
                )
            }
        }
    }

    func fetchImage(from url: URL) async throws -> UIImage {
        try await imageService.fetchImage(from: url)
    }

    func fetchHomeScreen() {
        fetchTabs()
        fetchHome()
    }
}
