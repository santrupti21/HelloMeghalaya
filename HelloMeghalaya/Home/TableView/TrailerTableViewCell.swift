//
//  TrailerTableViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 28/09/26.
//

import UIKit

final class TrailerTableViewCell: UITableViewCell {
    
    static let identifier = "TrailerTableViewCell"
    
    let thumbnailImageView = UIImageView()
    let titleLabel = UILabel()
    let captionLabel = UILabel()
    
    private let textStackView = UIStackView()
    
    private var imageTask: Task<Void, Never>?
    private var representedImageURL: URL?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.backgroundColor = .darkGray
        
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(
            ofSize: 20,
            weight: .semibold
        )
        titleLabel.numberOfLines = 0
        
        captionLabel.textColor = .lightGray
        captionLabel.font = .systemFont(ofSize: 16)
        captionLabel.numberOfLines = 0
        
        
        textStackView.axis = .vertical
        textStackView.spacing = 8
        textStackView.alignment = .fill
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(captionLabel)
        
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(textStackView)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            // Image at the top, with horizontal padding
            thumbnailImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            
            thumbnailImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            
            thumbnailImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            
            // Maintain a 16:9 image ratio
            thumbnailImageView.heightAnchor.constraint(
                equalTo: thumbnailImageView.widthAnchor,
                multiplier: 9.0 / 16.0
            ),
            
            // Title and caption below the image
            textStackView.topAnchor.constraint(
                equalTo: thumbnailImageView.bottomAnchor,
                constant: 32
            ),
            
            textStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 32
            ),
            
            textStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -32
            ),
            
            textStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -28
            )
        ])
    }
    
    func configure(
        with trailer: HomeItem,
        imageLoader: @escaping (URL) async throws -> UIImage
    ) {
        titleLabel.text = trailer.displayTitle ?? "Untitled"
        captionLabel.text = trailer.itemCaption
        imageTask?.cancel()
        imageTask = nil

        thumbnailImageView.image = nil
        representedImageURL = nil

        // Get the trailer thumbnail URL
        guard let urlString = trailer.thumbnails?.xlImage16_9?.url,
              let url = URL(string: urlString) else {
            return
        }

        representedImageURL = url

        imageTask = Task { [weak self] in
            do {
                let image = try await imageLoader(url)

                guard !Task.isCancelled,
                      let self,
                      self.representedImageURL == url else {
                    return
                }

                self.thumbnailImageView.image = image

            } catch {
                guard !Task.isCancelled else { return }
                print("Failed to load trailer image:", error)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTask?.cancel()
        imageTask = nil
        
        representedImageURL = nil
        thumbnailImageView.image = nil
    }
}
