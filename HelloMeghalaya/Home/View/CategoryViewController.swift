//
//  CategoryViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 26/08/26.
//

import UIKit

@MainActor
final class CategoryViewController: UIViewController {

    private let section: HomeSection
    private let viewModel: HomeViewModel
    private let friendlyID: String
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let collectionView: UICollectionView
    
    private var currentPage = 0
    private var isLoading = false // prevents duplicate req
    private var hasMoreData = true// prevnts req after no more data
    
    private var items: [HomeItem] = []
    private let layoutType: String?

    //Depencdency injection-> viewmodel
    init(
        section: HomeSection,
        friendlyID: String,
        viewModel: HomeViewModel
    ) {
        self.section = section
        self.friendlyID = friendlyID
        self.viewModel = viewModel
        self.items = section.catalogListItems ?? []
        self.layoutType = section.catalogListItems?
            .first?
            .catalogObject?
            .layoutType

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(
            top: 20,
            left: 16,
            bottom: 20,
            right: 16
        )

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupUI()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true

        collectionView.register(
            CategoryContentCollectionViewCell.self,
            forCellWithReuseIdentifier: "CategoryContentCell"
        )

        print("CATEGORY LAYOUT TYPE:", layoutType ?? "nil")
        print("CATEGORY FRIENDLY ID:", friendlyID)
        print("CATEGORY INITIAL ITEMS:", items.count)
    }

    private func setupUI() {

        titleLabel.text = section.displayTitle
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(
            ofSize: 24,
            weight: .semibold
        )
        titleLabel.textAlignment = .center

        backButton.setImage(
            UIImage(systemName: "chevron.left"),
            for: .normal
        )
        backButton.tintColor = .systemGreen
        backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        collectionView.backgroundColor = .clear

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10
            ),

            backButton.widthAnchor.constraint(
                equalToConstant: 40
            ),

            backButton.heightAnchor.constraint(
                equalToConstant: 40
            ),

            titleLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            titleLabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            collectionView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: 10
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func loadNextPage() {

        guard !isLoading else {
            return
        }

        guard hasMoreData else {
            return
        }

        let nextPage = currentPage + 1

        isLoading = true

        Task { [weak self] in

            guard let self else {
                return
            }

            do {

                let newItems = try await self.viewModel.fetchCategoryPage(
                    homeLink: self.friendlyID,
                    page: nextPage
                )

                if newItems.isEmpty {

                    print("CATEGORY: PAGE \(nextPage) RETURNED 0 ITEMS")

                } else {

                    let startIndex = self.items.count

                    self.items.append(contentsOf: newItems)

                    self.currentPage = nextPage

                    let indexPaths = (startIndex..<self.items.count).map {
                        IndexPath(
                            item: $0,
                            section: 0
                        )
                    }

                    self.collectionView.performBatchUpdates {

                        self.collectionView.insertItems(
                            at: indexPaths
                        )
                    }
                }

                self.isLoading = false

            } catch {

                self.isLoading = false

                print(
                    "CATEGORY PAGINATION FAILED:",
                    error
                )
            }
        }
    }
}

extension CategoryViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryContentCell",
            for: indexPath
        ) as? CategoryContentCollectionViewCell else {

            return UICollectionViewCell()
        }

        let item = items[indexPath.item]

        cell.configure(
            with: item,
            layoutType: layoutType,
            viewModel: viewModel
        )

        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let sideInset: CGFloat = 16
        let spacing: CGFloat = 8

        let columns: CGFloat =
            layoutType == "t_2_3_movie" ? 3 : 2

        let availableWidth =
            collectionView.bounds.width
            - (sideInset * 2)
            - (spacing * (columns - 1))

        let cellWidth = availableWidth / columns

        let aspectRatio: CGFloat =
            layoutType == "t_2_3_movie"
            ? 3.0 / 2.0
            : 9.0 / 16.0

        let cellHeight = cellWidth * aspectRatio

        return CGSize(
            width: cellWidth,
            height: cellHeight
        )
    }

    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {

        guard !isLoading else {
            return
        }

        guard hasMoreData else {
            return
        }

        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        let offset = scrollView.contentOffset.y

        let threshold: CGFloat = 200

        guard offset + visibleHeight >= contentHeight - threshold else {
            return
        }

        loadNextPage()
    }
}
