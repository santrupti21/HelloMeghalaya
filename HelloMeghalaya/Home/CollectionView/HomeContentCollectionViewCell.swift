//
//  HomeContentCellCollectionViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 18/08/26.
//

import UIKit

final class HomeContentCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private var imageTask: Task<Void, Never>?
    
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
        imageView.backgroundColor = .darkGray

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false


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

            landscapeAspectRatioConstraint,

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: 8
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    func configure(
        with item: HomeItem,
        layoutType: String?,
        viewModel: HomeViewModel
    ) {
        imageTask?.cancel()

        imageView.image = nil
        titleLabel.text = item.displayTitle

        if layoutType == "t_2_3_movie" {
            landscapeAspectRatioConstraint.isActive = false
            portraitAspectRatioConstraint.isActive = true
        } else {
            portraitAspectRatioConstraint.isActive = false
            landscapeAspectRatioConstraint.isActive = true
        }

        let imageURLString: String?

        if layoutType == "t_2_3_movie" {
            imageURLString = item.thumbnails.large2_3?.url
        } else {
            imageURLString = item.thumbnails.large16_9?.url
        }

        guard
            let imageURLString,
            let url = URL(string: imageURLString)
        else {
            return
        }

        imageTask = Task { [weak self] in
            do {
                let image = try await viewModel.fetchImage(from: url)

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

                print("Image Loading failed:", error)
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
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
}
