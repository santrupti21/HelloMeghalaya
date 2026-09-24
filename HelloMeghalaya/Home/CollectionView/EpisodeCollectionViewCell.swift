//
//  EpisodeCollectionViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 23/09/26.
//

import UIKit

final class EpisodeCollectionViewCell: UICollectionViewCell {
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let downloadButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = UIColor(red: 0.12, green: 0.11, blue: 0.09, alpha: 1)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        thumbnailImageView.contentMode = .scaleToFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.image = UIImage(named: "imagePlaceholder16x9")
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.numberOfLines = 1
        
        downloadButton.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
        downloadButton.tintColor = .systemGray
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(downloadButton)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Thumbnail
            thumbnailImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            
            thumbnailImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            
            thumbnailImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            thumbnailImageView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: 0.43
            ),
            
            // Title
            titleLabel.leadingAnchor.constraint(
                equalTo: thumbnailImageView.trailingAnchor,
                constant: 32
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 25
            ),
            
            titleLabel.trailingAnchor.constraint(
                equalTo: downloadButton.leadingAnchor,
                constant: -10
            ),
            
            // Subtitle
            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 10
            ),
            
            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),
            
            // Download
            downloadButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            
            downloadButton.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            
            downloadButton.widthAnchor.constraint(
                equalToConstant: 40
            ),
            
            downloadButton.heightAnchor.constraint(
                equalToConstant: 40
            )
        ])
        
}
    
    func configure(with episode: Episode, fetchImage: @escaping (URL) async throws -> UIImage) {
        
        titleLabel.text = episode.title ?? ""
        subtitleLabel.text = episode.itemCaption ?? ""
        
        thumbnailImageView.image = UIImage(named: "imagePlaceholder16x9")
        
        guard let urlString = episode.thumbnails?.xlImage16x9?.url,
              let url = URL(string: urlString)
                
        else {
            return
        }
        
        Task {
            do {
                let image = try await fetchImage(url)
                
                await MainActor.run {
                    self.thumbnailImageView.image = image
                }
            } catch {
                print("Episode thumbnail loading failed:", error)
            }
        }
    }
    
    
}
