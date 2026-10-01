//
//  TrailersViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 28/09/26.
//

import UIKit


final class TrailersViewController: UIViewController {
    
    private let viewModel = TrailersViewModel()
    private let tableView = UITableView()
    private let navigationBarView = NavigationBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = nil
        view.backgroundColor = .black
        
        setupNavigationBar()
        setupTableView()
        fetchTrailers()
    }
    
    private func setupTableView() {
            tableView.backgroundColor = .black
            tableView.separatorColor = .darkGray
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
            tableView.dataSource = self
        tableView.delegate = self

            tableView.register(
                TrailerTableViewCell.self,
                forCellReuseIdentifier: TrailerTableViewCell.identifier
            )

            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(
                    equalTo: navigationBarView.bottomAnchor
                ),
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
                ),
                tableView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
                ),
                tableView.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor
                )
            ])
        }
    
    private func setupNavigationBar() {
        navigationBarView.showsTabs = false
        view.addSubview(navigationBarView)
        
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
      navigationBarView.updateTabs([]) //no tabs
        
        navigationBarView.onSearchTapped = { [weak self] in
            guard let self else { return }

            let searchViewController = SearchViewController()

            if let navigationController = self.navigationController {
              
                navigationController.pushViewController(
                    searchViewController,
                    animated: true
                )
            } else {
          
                let navigationController = UINavigationController(
                    rootViewController: searchViewController
                )

                navigationController.modalPresentationStyle = .fullScreen

                self.present(
                    navigationController,
                    animated: true
                )
            }
        }
    }

        private func fetchTrailers() {
            Task {
                await viewModel.fetchTrailers()

                tableView.reloadData()
            }
        }
    }
    
extension TrailersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.trailers.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrailerTableViewCell.identifier,
            for: indexPath
        ) as? TrailerTableViewCell else {
            return UITableViewCell()
        }

        let trailer = viewModel.trailers[indexPath.row]

        cell.configure(with: trailer) { [weak self] url in
            guard let self else {
                throw CancellationError()
            }

            return try await self.viewModel.fetchImage(from: url)
        }

        return cell
    }
}

extension TrailersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let trailer = viewModel.trailers[indexPath.row]
        
        print("Selected Trailer:", trailer.displayTitle ?? "")
        print("Catalog ID:", trailer.catalogID)
        print("Content ID:", trailer.contentID)
        
        let detailsViewModel = MovieDetailsViewModel(catalogId: trailer.catalogID, contentId: trailer.contentID)
        
        let detailsViewController = MovieDetailsViewController(
               viewModel: detailsViewModel
           )
        
        if let navigationController = self.navigationController {
                   navigationController.pushViewController(
                       detailsViewController,
                       animated: true
                   )
               } else {
                   let navigationController = UINavigationController(
                       rootViewController: detailsViewController
                   )

                   navigationController.modalPresentationStyle = .fullScreen

                   present(navigationController, animated: true)
               }

               tableView.deselectRow(at: indexPath, animated: true)

    }
}
