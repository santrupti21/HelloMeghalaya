//
//  HomeBannerTableViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 19/08/26.
//

import UIKit

final class HomeBannerTableViewCell: UITableViewCell {
    
    private let collectionView: UICollectionView
    
    private let pageControl = UIPageControl()
    
    private var items: [HomeItem] = []
    
    private var autoScrollTimmer: Timer?
    
    private  var viewModel: HomeViewModel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

           backgroundColor = .clear
           contentView.backgroundColor = .clear
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.scrollIndicatorInsets = .zero
        
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(HomeSliderCell.self, forCellWithReuseIdentifier: "HomeSliderCell")

           contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)

           collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
           collectionView.backgroundColor = .clear

           NSLayoutConstraint.activate([
               collectionView.leadingAnchor.constraint(
                   equalTo: contentView.leadingAnchor
               ),
               collectionView.trailingAnchor.constraint(
                   equalTo: contentView.trailingAnchor
               ),
               collectionView.topAnchor.constraint(
                   equalTo: contentView.topAnchor
               ),
               collectionView.bottomAnchor.constraint(
                equalTo: pageControl.topAnchor, constant: -5
               ),
               
               pageControl.centerXAnchor.constraint(
                   equalTo: contentView.centerXAnchor
               ),

               pageControl.bottomAnchor.constraint(
                   equalTo: contentView.bottomAnchor
               )
           ])
       }
    
    func configure(
        with items: [HomeItem],
        viewModel: HomeViewModel
    ) {
        self.items = items
        self.viewModel = viewModel

        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0

        collectionView.reloadData()
        startAutoScroll()
    }
    
    private func startAutoScroll() {
        autoScrollTimmer?.invalidate()
        
        autoScrollTimmer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.scrollToNextItem()
        }
        
    }
    
    private func scrollToNextItem() {
        guard !items.isEmpty else {
            return
        }
        
        let pageWidth = collectionView.bounds.width
        
        guard pageWidth > 0 else {
            return
        }
        
        let currentIndex = Int(round(collectionView.contentOffset.x / pageWidth))
        
        let nextIndex = (currentIndex + 1) % items.count
        
        let offsetX = CGFloat(nextIndex) * pageWidth
        
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        autoScrollTimmer?.invalidate()
        autoScrollTimmer = nil

        items = []

        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
    }
}

extension HomeBannerTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSliderCell", for: indexPath) as? HomeSliderCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.item]

        cell.configure(
            with: item,
            viewModel: viewModel
        )

        return cell
    }

    
}

extension HomeBannerTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width

        return CGSize(
            width: width,
            height: width * 9.0 / 16.0
        )
    }
}

extension HomeBannerTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = collectionView.bounds.width
        
        guard pageWidth > 0 else {
            return
        }
        
        let currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
        
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let pageWidth = collectionView.bounds.width
        
        guard pageWidth > 0 else {
            return
        }
        
        let currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
        pageControl.currentPage = currentPage
    }
}
