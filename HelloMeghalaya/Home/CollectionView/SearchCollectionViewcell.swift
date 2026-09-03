//
//  SearchCollectionViewcell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 01/09/26.
//

import UIKit

final class SearchCollectionViewcell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    private var imageTask: Task<Void, Never>?
    
    private let landscapePlaceholder = UIImage(named: "imagePlaceholder16x9")
    private let portraitPlaceholder = UIImage(named: "imagePlaceholder2x3")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(
            ofSize: 14,
            weight: .medium
        )

        titleLabel.numberOfLines = 1

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),

            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            imageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: 8
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    func configure(
        with item: HomeItem,
        viewModel: SearchViewModel
    ) {
        imageTask?.cancel()
        
        let isPortrait = item.catalogObject?.layoutType?.contains("2_3") == true
        
        if isPortrait {
            imageView.image = portraitPlaceholder
        } else {
            imageView.image = landscapePlaceholder
        }
        
        titleLabel.text = item.displayTitle

        let imageURL = isPortrait
            ? item.thumbnails?.large2_3?.url
            : item.thumbnails?.large16_9?.url

        guard let imageURL,
              let url = URL(string: imageURL) else {
            return
        }

        imageTask = Task { [weak self] in
            do {
                let image = try await viewModel.fetchImage(from: url)

                guard !Task.isCancelled else {
                    return
                }

                self?.imageView.image = image

            } catch {
                guard !Task.isCancelled else {
                    return
                }

                print("Search image error:", error)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil

        imageView.image = nil
        titleLabel.text = nil
    }
}
