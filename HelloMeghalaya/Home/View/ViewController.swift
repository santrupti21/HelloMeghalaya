//
//  ViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 12/08/26.
//

import UIKit

@MainActor
final class ViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private let navigationBarView = NavigationBarView()
    private let homeTableView = UITableView()
    
    private var homeSections: [HomeSection] = []
    private var homeSliderItems: [HomeItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        viewModel.delegate = self
        
        navigationBarView.onTabSelected = { [weak self] tab in
            
            guard let self else { return }
            
            guard let catalogType = CatalogType(friendlyID: tab.friendlyID) else {
                return
            }
            print("Selected catalog:", catalogType)
            
            self.viewModel.changeCatalogType(
                to: catalogType
            )
        }
        
        homeTableView.dataSource = self
        homeTableView.delegate = self
        
        homeTableView.register(HomeSectionTableViewCell.self, forCellReuseIdentifier: "HomeSectionTableViewCell")
        
        homeTableView.register(HomeBannerTableViewCell.self, forCellReuseIdentifier: "HomeBannerTableViewCell")
        
        setupNavigationBar()
        setupHomeTableView()
        
        viewModel.fetchHomeScreen()
        
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBarView)
        
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            
            navigationBarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            
            navigationBarView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            )
            
        ])
    }
    
    private func setupHomeTableView() {
        
        homeTableView.backgroundColor = .clear
        homeTableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(homeTableView)
        
        homeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            homeTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            homeTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            homeTableView.topAnchor.constraint(
                equalTo: navigationBarView.bottomAnchor
            ),
            homeTableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.clearImageCache()
    }
    
    func clearImageCache() {
        viewModel.clearImageCache()
    }
    
    
}

extension ViewController: HomeViewModelDelegate {
    func homeViewModel(_ viewModel: HomeViewModel, didUpdateTabs tabs: [CatalogTab]) {
        navigationBarView.updateTabs(tabs)
    }
    
    
    func homeViewModel(_ viewModel: HomeViewModel, didFailWith error: Error) {
        print("Home Error:", error)
    }
    
    func homeViewModel(
        _ viewModel: HomeViewModel,
        didUpdateHomeSections sections: [HomeSection]
    ) {

        homeSections = sections

        print("Sections received:", sections.count)

        homeTableView.reloadData()
    }
    
    func homeViewModel(_ viewModel: HomeViewModel, didUpdateHomeSlider items: [HomeItem]) {
        homeSliderItems = items
        homeTableView.reloadData()
    }

    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeSections.count + 1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HomeBannerTableViewCell",
                for: indexPath
            ) as? HomeBannerTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(with: homeSliderItems, viewModel: viewModel)

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HomeSectionTableViewCell",
            for: indexPath
        ) as? HomeSectionTableViewCell else {
            return UITableViewCell()
        }

        cell.backgroundColor = .clear

        let section = homeSections[indexPath.row - 1]

        cell.configure(with: section, viewModel: viewModel)

        return cell
    }
    
    
}


extension ViewController: UITableViewDelegate {
    //Table view row height
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        if indexPath.row == 0 {
            return (tableView.bounds.width * 9.0 / 16.0) + 40
        }
        
        let section = homeSections[indexPath.row - 1]
        
        let collectionWidth = tableView.bounds.width - 20
        let cardWidth = collectionWidth * 0.55
        
        let layoutType = section.catalogListItems?.first?.catalogObject?.layoutType
        
        let imageHeight: CGFloat
        
        if layoutType == "t_2_3_movie" {
            imageHeight = cardWidth * 3.0 / 2.0
        } else {
            imageHeight = cardWidth * 9.0 / 16.0
        }
        
        let collectionHeight = imageHeight + 8 + 40
        
        return 10 + 30 + 10 + collectionHeight + 10
    }
        
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {

        let contentHeight = scrollView.contentSize.height
        let currentOffset = scrollView.contentOffset.y
        let visibleHeight = scrollView.bounds.height

        // Don't paginate if the table isn't actually scrollable
        guard contentHeight > visibleHeight else {
            return
        }

        let threshold: CGFloat = 300

        let reachedThreshold =
            currentOffset + visibleHeight >=
            contentHeight - threshold

        guard reachedThreshold else {
            return
        }

        viewModel.loadNextPage()
    }
}

