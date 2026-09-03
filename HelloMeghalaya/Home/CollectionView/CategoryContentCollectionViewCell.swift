//
//  CategoryContentCollectionViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 26/08/26.
//

import UIKit

final class CategoryContentCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let landscapePlaceholder =
        UIImage(named: "imagePlaceholder16x9")

    private let portraitPlaceholder =
        UIImage(named: "imagePlaceholder2x3")
    private var imageTask: Task<Void, Never>?
    private var viewModel: HomeViewModel!
    
    private lazy var landscapeAspectRatioConstraint =
        imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor,
            multiplier: 9.0 / 16.0
        )

    private lazy var portraitAspectRatioConstraint =
        imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor,
            multiplier: 3.0 / 2.0
        )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10

        contentView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    func configure(
        with item: HomeItem,
        layoutType: String?,
        viewModel: HomeViewModel
    ) {

        self.viewModel = viewModel

        imageTask?.cancel()

        if layoutType == "t_2_3_movie" {

            imageView.image = portraitPlaceholder

            landscapeAspectRatioConstraint.isActive = false
            portraitAspectRatioConstraint.isActive = true

        } else {

            imageView.image = landscapePlaceholder

            portraitAspectRatioConstraint.isActive = false
            landscapeAspectRatioConstraint.isActive = true
        }

        let imageURLString: String?

        if layoutType == "t_2_3_movie" {

            imageURLString = item.thumbnails?.large2_3?.url

        } else {

            imageURLString = item.thumbnails?.large16_9?.url
        }

        guard
            let imageURLString,
            let url = URL(string: imageURLString)
        else {
            return
        }  //This safely unwraps the optional URL and converts it into a URL.
       // If either is invalid, the cell simply stops.
        
        
        imageTask = Task { [weak self] in

            do {

                let image = try await viewModel.fetchImage(
                    from: url
                )

                guard !Task.isCancelled else {
                    return
                }

                await MainActor.run { [weak self] in
                    self?.imageView.image = image
                }

            } catch {

                guard !Task.isCancelled else {
                    return
                }

                print(
                    "Category image loading failed:",
                    error
                )
            }
        }
    }
    
    override func prepareForReuse() {

        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil

        landscapeAspectRatioConstraint.isActive = false
        portraitAspectRatioConstraint.isActive = false

        imageView.image = nil
    }

}
