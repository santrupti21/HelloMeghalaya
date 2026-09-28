//
//  ShortsTableViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 25/09/26.
//

import UIKit
import AVFoundation

final class ShortsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ShortsTableViewCell"
    
    private let titleLabel = UILabel()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    
    private let titleContainerView = UIView()
    
    private let actionsStackView = UIStackView()
    
    private let likeButton = UIButton(type: .system)
    private let addToListButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let muteButton = UIButton(type: .system)
    
    private let likeCountLabel = UILabel()
    
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

        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        contentView.addSubview(titleContainerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 2

        titleContainerView.addSubview(titleLabel)


        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = .vertical
        actionsStackView.alignment = .center
        actionsStackView.spacing = 20

        contentView.addSubview(actionsStackView)

        styleActionButton(likeButton, image: "hand.thumbsup")
        styleActionButton(addToListButton, image: "plus.square")
        styleActionButton(shareButton, image: "square.and.arrow.up")
        styleActionButton(muteButton, image: "speaker.wave.2")
        
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)

      //  likeCountLabel.text = "140"
        likeCountLabel.textColor = .white
        likeCountLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        let likeStackView = UIStackView(
            arrangedSubviews: [likeButton, likeCountLabel]
        )
        likeStackView.axis = .vertical
        likeStackView.alignment = .center
        likeStackView.spacing = 4

        actionsStackView.addArrangedSubview(likeStackView)
        actionsStackView.addArrangedSubview(addToListButton)
        actionsStackView.addArrangedSubview(shareButton)
        actionsStackView.addArrangedSubview(muteButton)

        NSLayoutConstraint.activate([
            // Bottom title bar
            titleContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            titleContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            titleContainerView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            titleContainerView.heightAnchor.constraint(equalToConstant: 56),

            // Title
            titleLabel.leadingAnchor.constraint(
                equalTo: titleContainerView.leadingAnchor,
                constant: 20
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: titleContainerView.trailingAnchor,
                constant: -20
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: titleContainerView.centerYAnchor
            ),

            // Right-side actions
            actionsStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            actionsStackView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            // Button sizes
            likeButton.widthAnchor.constraint(equalToConstant: 56),
            likeButton.heightAnchor.constraint(equalToConstant: 56),

            addToListButton.widthAnchor.constraint(equalToConstant: 56),
            addToListButton.heightAnchor.constraint(equalToConstant: 56),

            shareButton.widthAnchor.constraint(equalToConstant: 56),
            shareButton.heightAnchor.constraint(equalToConstant: 56),

            muteButton.widthAnchor.constraint(equalToConstant: 56),
            muteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func styleActionButton(
        _ button: UIButton,
        image: String
    ) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(systemName: image),
            for: .normal
        )

        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        button.layer.cornerRadius = 28
        button.clipsToBounds = true

        button.imageView?.contentMode = .scaleAspectFit
    }
    
    func configure(with short: ShortItem) {
        titleLabel.text = short.displayTitle
        setupPlayer(with: short.videoURL)
    }
    
    private func setupPlayer(with urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString) else {
            print("Invalid video URL")
            return
        }

        // Clean up the previous player
        player?.pause()
        playerLayer?.removeFromSuperlayer()

        let item = AVPlayerItem(url: url)
        playerItem = item

        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer

        let newPlayerLayer = AVPlayerLayer(player: newPlayer)
        newPlayerLayer.videoGravity = .resizeAspectFill
        newPlayerLayer.frame = contentView.bounds

        contentView.layer.insertSublayer(newPlayerLayer, at: 0)
        contentView.bringSubviewToFront(titleContainerView)
        contentView.bringSubviewToFront(actionsStackView)
        playerLayer = newPlayerLayer

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
   
    }
    
    @objc private func toggleMute() {
        guard let player else {
            return
        }
        
        player.isMuted.toggle()
        
        let imageName = player.isMuted ? "speaker.slash" : "speaker.wave.2"
        
        muteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        playerItem = nil
        player = nil
    }
    func playVideo() {
        player?.play()
    }
    
    func pauseVideo() {
        player?.pause()
    }
}
