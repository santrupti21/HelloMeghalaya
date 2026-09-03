//
//  NavigationBarView.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 12/08/26.


import UIKit

final class NavigationBarView: UIView {


    private let logoImageView = UIImageView()

    private let searchButton = UIButton(type: .system)

    private let collectionView: UICollectionView


    private var tabs: [CatalogTab] = []

    private var selectedIndex = 0 //keep track of which index is selected
    
    var onTabSelected: ((CatalogTab) -> Void)? //closure
    var onSearchTapped: (() -> Void)?

    override init(frame: CGRect) {

        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal

        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    private func setupUI() {

        backgroundColor = UIColor(
            red: 0.10,
            green: 0.10,
            blue: 0.10,
            alpha: 1
        )

        setupLogo()

        setupSearchButton()

        setupCollectionView()
    }

 

    private func setupLogo() {

        logoImageView.image = UIImage(named: "HMlogo")

        logoImageView.contentMode = .scaleAspectFit

        addSubview(logoImageView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoWidthConstraint = logoImageView.widthAnchor.constraint(
            equalTo: safeAreaLayoutGuide.widthAnchor,
            multiplier: 0.25
        )

        let logoHeightConstraint = logoImageView.heightAnchor.constraint(
            equalTo: logoImageView.widthAnchor,
            multiplier: 80.0 / 130.0
        )
        
        NSLayoutConstraint.activate([

            logoImageView.leadingAnchor.constraint(
                equalTo:
                    safeAreaLayoutGuide.leadingAnchor,
                constant: 30
            ),

            logoImageView.topAnchor.constraint(
                equalTo:
                    safeAreaLayoutGuide.topAnchor,
                constant: 10
            ),
            logoWidthConstraint,
            logoHeightConstraint
        ])
    }

    private func setupSearchButton() {

        let searchImage = UIImage(systemName: "magnifyingglass")

        searchButton.setImage(searchImage, for: .normal)

        searchButton.tintColor = .white
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        addSubview(searchButton)

        searchButton.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([

            searchButton.trailingAnchor.constraint(
                equalTo:
                    safeAreaLayoutGuide.trailingAnchor,
                constant: -30
            ),

            searchButton.centerYAnchor.constraint(
                equalTo:
                    logoImageView.centerYAnchor
            ),

            searchButton.widthAnchor.constraint(
                equalToConstant: 44
            ),

            searchButton.heightAnchor.constraint(
                equalToConstant: 44
            )
        ])
    }
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CatalogTabCell.self,
            forCellWithReuseIdentifier: "CatalogTabCell"
        )

        addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 30
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -30
            ),
            collectionView.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 10
            ),
            collectionView.heightAnchor.constraint(
                equalToConstant: 45
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -10
            )
        ])
    }
    
    @objc private func searchButtonTapped() {
        onSearchTapped?()
    }


    func updateTabs(
        _ tabs: [CatalogTab]
    ) {

        self.tabs = tabs

        collectionView.reloadData()
    }
}


extension NavigationBarView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return tabs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CatalogTabCell",
            for: indexPath) as? CatalogTabCell else {

            return UICollectionViewCell()
        }

        let tab = tabs[indexPath.item]

        cell.configure(title: tab.displayTitle, isSelected: indexPath.item == selectedIndex)

        return cell
    }
}


extension NavigationBarView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout:
            UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let font = UIFont.systemFont(
            ofSize: 12,
            weight: .medium
        )

  let minimumWidths = tabs.map { tab in tab.displayTitle.size(withAttributes: [.font: font]).width + 40}

        let minimumWidth = minimumWidths[indexPath.item]


        let totalMinimumWidth = minimumWidths.reduce(0, +)
        //start from 0-> add all vallues

        let spacing = CGFloat(max(tabs.count - 1, 0)) * 10


        let availableWidth = collectionView.bounds.width - spacing

 
        if totalMinimumWidth < availableWidth {

            let extraWidth = (availableWidth - totalMinimumWidth) / CGFloat(tabs.count)

            return CGSize(width: minimumWidth + extraWidth, height: font.lineHeight + 20)
        }

        return CGSize(width: minimumWidth, height: font.lineHeight + 20)
    }
}


extension NavigationBarView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        selectedIndex = indexPath.item

        collectionView.reloadData()
        
        let selectedTab = tabs[indexPath.item]
        onTabSelected?(selectedTab)
       
    }
    
    
}

