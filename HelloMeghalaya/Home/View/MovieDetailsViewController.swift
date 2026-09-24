//
//  MovieDetailsViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 09/09/26.
//

import UIKit
import AVFoundation

enum VideoQuality {
    case auto
    case p360
    case p480
    case p720
    case p1080
}

enum PlaybackSpeed {
    case half //0.5
    case normal //1x
    case oneAndHalf //1.5
    case oneAndSeventyFive //1.75
    case double //2x
    
    var rate: Float {
            switch self {
            case .half:
                return 0.5
            case .normal:
                return 1.0
            case .oneAndHalf:
                return 1.5
            case .oneAndSeventyFive:
                return 1.75
            case .double:
                return 2.0
            }
        }
}
enum DetailsType {
    case movie
    case show
    case episode
}

final class MovieDetailsViewController: UIViewController {
    
    private let viewModel: MovieDetailsViewModel
    
    private var playerView = UIView()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    
    private let playPauseButton = UIButton(type: .system)
    private let backwardButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationlabel = UILabel()
    private let fullscreenButton = UIButton(type: .system)
    private let qualityButton = UIButton(type: .system)
    private let playbackSpeedButton = UIButton(type: .system)
    private var isFullscreen = false
    
    private var timeObserver: Any?
    
    private let posterImageView = UIImageView()
    
    private let titleLabel = UILabel()//movie content title
    private let headerTitlelabel = UILabel()
    private let genreLabel = UILabel()
    private let watchNowButton = UIButton(type: .system)
    private let actionStackView = UIStackView()
    private let descriptionLabel = UILabel()
    
    private let languageStackView = UIStackView()// garao khasi
    
    private var languageStackTopConstraint: NSLayoutConstraint!
    private var languageStackHeightConstraint: NSLayoutConstraint!
    
    private let descriptionToggleButton = UIButton(type: .system)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backButton = UIButton(type: .system)
    
    private let landscapeBackButton = UIButton(type: .system)
    private let landscapeTitleLabel = UILabel()
    
    private let recommendedTitlelabel = UILabel()
    private let recommendedCollectionView: UICollectionView
    
    private let episodeCollectionView: UICollectionView
    
    private var detailsType: DetailsType
    
    private var descriptionTopConstraint: NSLayoutConstraint!
    private var movieDescriptionTopConstraint: NSLayoutConstraint!
    private var showDescriptionTopConstraint: NSLayoutConstraint!
    private var recommendedBottomConstraint: NSLayoutConstraint!
    private var episodeBottomConstraint: NSLayoutConstraint!
    private var episodeTopConstraint: NSLayoutConstraint!
    private var descriptionBottomConstraint: NSLayoutConstraint!
    private var episodeLanguageTopConstraint: NSLayoutConstraint!
    
    private var selectedQuality: VideoQuality = .auto
    private var selectedPlaybackSpeed: PlaybackSpeed = .normal
    
    private var hlsVariants: [AVAssetVariant] = []
    
    private let bufferingIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        self.detailsType = .movie

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10

        self.recommendedCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        let episodesLayout = UICollectionViewFlowLayout()
          episodesLayout.scrollDirection = .vertical
          episodesLayout.minimumLineSpacing = 10

          self.episodeCollectionView = UICollectionView(
              frame: .zero,
              collectionViewLayout: episodesLayout
          )
        super.init(nibName: nil, bundle: nil)

        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        view.backgroundColor = .black
        setupUI()
        
        
        updateOrientationUI(isLandscape: UIDevice.current.orientation.isLandscape)
        
        Task {
            do {
                // 1. Movie Details API
                try await viewModel.fetchMovieDetails()
                print("Movie details loaded")
                self.detailsType = viewModel.detailsType
                
                

                // 2. Display Movie Details
                if viewModel.detailsType == .episode,
                   let episode = viewModel.episode {

                    // MARK: - Episode Details

                    headerTitlelabel.text = episode.title
                    landscapeTitleLabel.text = episode.title
                    titleLabel.text = episode.title
                    genreLabel.text = episode.itemCaption
                    descriptionLabel.text = episode.description

                    playerView.isHidden = true
                    posterImageView.isHidden = false

                    if let imageURLString = episode.thumbnails?.xlImage16x9?.url,
                       let imageURL = URL(string: imageURLString) {

                        Task {
                            if let image = try? await viewModel.fetchImage(from: imageURL) {
                                await MainActor.run {
                                    self.posterImageView.image = image
                                }
                            }
                        }
                    }

                    // MARK: - Episode Layout

                    // Show language buttons
                    languageStackView.isHidden = false
                    languageStackHeightConstraint.constant = 40

                    // For Episode:
                    // Description
                    // ↓
                    // Garo / Khasi
                    // ↓
                    // Episodes

                    languageStackTopConstraint.isActive = false
                    episodeLanguageTopConstraint.isActive = true

                    // Create Garo / Khasi dynamically
                    setupLanguages()

                    // Hide Recommended
                    recommendedTitlelabel.isHidden = true
                    recommendedCollectionView.isHidden = true

                    // Show Episodes
                    episodeCollectionView.isHidden = false

                    // Show all Episode actions
                    actionStackView.arrangedSubviews[0].isHidden = false
                    actionStackView.arrangedSubviews[1].isHidden = false

                    // Description comes below action buttons
                    showDescriptionTopConstraint.isActive = false
                    movieDescriptionTopConstraint.isActive = true
                    descriptionTopConstraint.isActive = false

                    // Episode collection starts below language buttons
                    episodeTopConstraint.isActive = true

                    // Episode collection ends at contentView bottom
                    episodeBottomConstraint.isActive = true

                    // Recommended is not used
                    recommendedBottomConstraint.isActive = false

                    // Description itself does not end the content
                    descriptionBottomConstraint.isActive = false

                    view.layoutIfNeeded()

                    // Decide whether the description needs the
                    // expand/collapse arrow
                    updateDescriptionToggle()
                }
                
             else if let details = viewModel.movieDetails {
                    headerTitlelabel.text = details.title
                    landscapeTitleLabel.text = details.title
                    titleLabel.text = details.title
                    genreLabel.text = details.itemCaption
                    descriptionLabel.text = details.description
                    
                    switch detailsType {
                    case .show:

                        languageStackView.isHidden = false
                        languageStackTopConstraint.constant = 20
                        languageStackHeightConstraint.constant = 40

                        setupLanguages()

                        recommendedTitlelabel.isHidden = true
                        recommendedCollectionView.isHidden = true

                        episodeCollectionView.isHidden = false

                        actionStackView.arrangedSubviews[0].isHidden = true
                        actionStackView.arrangedSubviews[1].isHidden = true

                        showDescriptionTopConstraint.isActive = true
                        movieDescriptionTopConstraint.isActive = false
                        descriptionTopConstraint.isActive = false

                        languageStackTopConstraint.isActive = true
                        episodeLanguageTopConstraint.isActive = false

                        recommendedBottomConstraint.isActive = false

                        episodeTopConstraint.isActive = true
                        episodeBottomConstraint.isActive = true

                        descriptionBottomConstraint.isActive = false

                    case .movie:

                        languageStackView.isHidden = true
                        languageStackTopConstraint.constant = 0
                        languageStackHeightConstraint.constant = 0

                        recommendedTitlelabel.isHidden = false
                        recommendedCollectionView.isHidden = false

                        episodeCollectionView.isHidden = true

                        actionStackView.arrangedSubviews[0].isHidden = false
                        actionStackView.arrangedSubviews[1].isHidden = false

                        showDescriptionTopConstraint.isActive = false
                        movieDescriptionTopConstraint.isActive = true
                        descriptionTopConstraint.isActive = false

                        recommendedBottomConstraint.isActive = true
                        episodeBottomConstraint.isActive = false
                        episodeTopConstraint.isActive = false
                        descriptionBottomConstraint.isActive = false

                        episodeLanguageTopConstraint.isActive = false
                    
                    case .episode:

                        if let episode = viewModel.episode {

                            titleLabel.text = episode.title
                            descriptionLabel.text = episode.description

                            if let imageURLString = episode.thumbnails?.xlImage16x9?.url,
                               let imageURL = URL(string: imageURLString) {

                                Task {
                                    if let image = try? await viewModel.fetchImage(from: imageURL) {
                                        posterImageView.image = image
                                    }
                                }
                            }
                        }

                        languageStackView.isHidden = false
                        languageStackTopConstraint.constant = 20
                        languageStackHeightConstraint.constant = 40

                        // Episode language buttons come after description
                        languageStackTopConstraint.isActive = false
                        episodeLanguageTopConstraint.isActive = true

                        setupLanguages()

                        recommendedTitlelabel.isHidden = true
                        recommendedCollectionView.isHidden = true

                        episodeCollectionView.isHidden = false

                        actionStackView.arrangedSubviews[0].isHidden = false
                        actionStackView.arrangedSubviews[1].isHidden = false

                        showDescriptionTopConstraint.isActive = false
                        movieDescriptionTopConstraint.isActive = true
                        descriptionTopConstraint.isActive = false

                        recommendedBottomConstraint.isActive = false

                        episodeTopConstraint.isActive = true
                        episodeBottomConstraint.isActive = true

                        descriptionBottomConstraint.isActive = false
                    }

                    view.layoutIfNeeded()
                    updateDescriptionToggle()

                    if details.contentType == "movie" {
                        if let previewURLString = details.preview?.previewURL,
                           let previewURL = URL(string: previewURLString) {
                            setupPlayer(with: previewURL)
                        } else {
                            showPoster(for: details)
                        }
                    } else {
                        showPoster(for: details)
                    }
                }

                // 3. Get All Details API
                do {
                    if viewModel.detailsType != .episode {
                        try await viewModel.fetchUserDetails()
                    }

                    print("Get All Details Loaded")

                    if let userDetails = viewModel.userDetails {
                        print("Is Subscribed:", userDetails.isSubscribed ?? false)
                        print("Like Count:", userDetails.userLikeCount ?? 0)
                        print("Adaptive URL:", userDetails.adaptiveURL ?? "No URL")
                    }

                } catch {
                    // Get All Details failure should NOT affect Movie Details UI
                    print("Get All Details API failed:", error)
                }

            } catch {
                // Movie Details API failure
                print("Movie Details API failed:", error)
            }
        }
    }
    
    private func inspectHLSAssest(url: URL) {
        let asset = AVURLAsset(url: url)
        
        Task {
            do {
                let isPlayable = try await asset.load(.isPlayable)
                print("HLS Asset Playable:", isPlayable)
                
                let variants = try await asset.load(.variants)
                self.hlsVariants = variants
                self.configureQualityMenu()
            
                print("Number of variants:", variants.count)
                
                for variant in variants {
                    print("Peak bitrate:", variant.peakBitRate ?? "")
                    print("Average bitate", variant.averageBitRate!)
                    
                    if let videoAttributes = variant.videoAttributes {
                        print("resolution:", videoAttributes.presentationSize.width, "x", videoAttributes.presentationSize.height)
                    }
                }
             
            } catch {
                print("HLS Asset Error:", error)
            }
        }
    }
    
    private func configureQualityMenu() {
        var actions: [UIAction] = []
        
        let autoAction = UIAction(title: "Auto", state: selectedQuality == .auto ? .on : .off) { [weak self] _ in
            self?.selectQuality(.auto)
        }
        
        actions.append(autoAction)
        
        let qualities: [(VideoQuality, String)] = [
            (.p360, "360P"),
            (.p480, "480P"),
            (.p720, "720P"),
            (.p1080, "1080P")
        ]
        
        for (quality, title) in qualities {
            guard variant(for: quality, from: hlsVariants) != nil else {
                continue
            }
            
            let action = UIAction(title: title, state: selectedQuality == quality ? .on : .off) { [weak self] _ in
                self?.selectQuality(quality)
            }
            actions.append(action)
        }
        
        qualityButton.menu = UIMenu(title: "Video Quality", children: actions)
    }
    
    private func configurePlaybackSpeedmenu() {
        let halfAction = UIAction(title: "0.5x", state: selectedPlaybackSpeed == .half ? .on : .off) { [weak self] _ in
            self?.selectPlaybackSpeed(.half)
        }
        
        let normalAction = UIAction(
              title: "1x",
              state: selectedPlaybackSpeed == .normal ? .on : .off
          ) { [weak self] _ in
              self?.selectPlaybackSpeed(.normal)
          }

          let oneAndHalfAction = UIAction(
              title: "1.5x",
              state: selectedPlaybackSpeed == .oneAndHalf ? .on : .off
          ) { [weak self] _ in
              self?.selectPlaybackSpeed(.oneAndHalf)
          }

          let oneAndSeventyFiveAction = UIAction(
              title: "1.75x",
              state: selectedPlaybackSpeed == .oneAndSeventyFive ? .on : .off
          ) { [weak self] _ in
              self?.selectPlaybackSpeed(.oneAndSeventyFive)
          }

          let doubleAction = UIAction(
              title: "2x",
              state: selectedPlaybackSpeed == .double ? .on : .off
          ) { [weak self] _ in
              self?.selectPlaybackSpeed(.double)
          }
        
        playbackSpeedButton.menu = UIMenu(title: "Playback Speed", children: [halfAction, normalAction, oneAndHalfAction, oneAndSeventyFiveAction, doubleAction])
        playbackSpeedButton.showsMenuAsPrimaryAction = true
    }
    
    private func selectPlaybackSpeed(_ speed: PlaybackSpeed) {
        selectedPlaybackSpeed = speed
        
        let rate: Float
        
        switch speed {
        case .half:
            rate = 0.5
            
        case .normal:
            rate = 1.0
            
        case .oneAndHalf:
            rate = 1.5
            
        case .oneAndSeventyFive:
            rate = 1.75
            
        case .double:
            rate = 2.0
        }
        player?.rate = rate
        configurePlaybackSpeedmenu()
        print("Playback speed:", rate)
    }
    
    private func variant(for quality: VideoQuality, from variants: [AVAssetVariant]) -> AVAssetVariant? {
        
        switch quality {
        case .auto:
            return nil
        case .p360:
            return variants.first {
                $0.videoAttributes?.presentationSize.height == 360
            }
        case .p480:
            return variants.first {
                $0.videoAttributes?.presentationSize.height == 480
            }
        case .p720:
            return variants.first {
                $0.videoAttributes?.presentationSize.height == 720
            }
        case .p1080:
            return variants.first {
                $0.videoAttributes?.presentationSize.height == 1080
            }
        }
        
    }
    
    
    private func setupUI() {
        
        headerTitlelabel.textColor = .white
        headerTitlelabel.font = .boldSystemFont(ofSize: 20)
        headerTitlelabel.textAlignment = .center
        headerTitlelabel.numberOfLines = 1

        backButton.setImage(
            UIImage(systemName: "chevron.left"),
            for: .normal
        )
        backButton.tintColor = .systemGreen


        view.addSubview(backButton)
        view.addSubview(headerTitlelabel)
        
        view.addSubview(playerView)
        playerView.clipsToBounds = true
        
        playerView.addSubview(playPauseButton)
        playerView.addSubview(backwardButton)
        playerView.addSubview(forwardButton)
        
        playerView.addSubview(landscapeBackButton)
        playerView.addSubview(landscapeTitleLabel)
        
        playerView.addSubview(bufferingIndicator)
        playerView.addSubview(progressSlider)
        playerView.addSubview(currentTimeLabel)
        playerView.addSubview(durationlabel)
        playerView.addSubview(fullscreenButton)
      
        playerView.addSubview(qualityButton)
        playerView.addSubview(playbackSpeedButton)
        
        view.addSubview(posterImageView)
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.isHidden = true
        
        view.addSubview(scrollView)

        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(genreLabel)
        contentView.addSubview(watchNowButton)
        contentView.addSubview(actionStackView)
        
        contentView.addSubview(languageStackView)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionToggleButton)
        
        contentView.addSubview(recommendedTitlelabel)
        contentView.addSubview(recommendedCollectionView)

        contentView.addSubview(episodeCollectionView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        landscapeBackButton.translatesAutoresizingMaskIntoConstraints = false
        landscapeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        bufferingIndicator.translatesAutoresizingMaskIntoConstraints = false
        bufferingIndicator.hidesWhenStopped = true
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationlabel.translatesAutoresizingMaskIntoConstraints = false
        fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        qualityButton.translatesAutoresizingMaskIntoConstraints = false
        playbackSpeedButton.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        watchNowButton.translatesAutoresizingMaskIntoConstraints = false
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        languageStackView.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        recommendedTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        episodeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        languageStackTopConstraint = languageStackView.topAnchor.constraint(
            equalTo: actionStackView.bottomAnchor,
            constant: 20
        )

        languageStackHeightConstraint = languageStackView.heightAnchor.constraint(
            equalToConstant: 40
        )
        
        descriptionTopConstraint = descriptionLabel.topAnchor.constraint(
            equalTo: languageStackView.bottomAnchor,
            constant: 12
        )
        
        movieDescriptionTopConstraint = descriptionLabel.topAnchor.constraint(
            equalTo: actionStackView.bottomAnchor,
            constant: 25
        )

        showDescriptionTopConstraint = descriptionLabel.topAnchor.constraint(
            equalTo: languageStackView.bottomAnchor,
            constant: 12
        )
        
        recommendedBottomConstraint = recommendedCollectionView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -20
        )

        episodeBottomConstraint = episodeCollectionView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -20
        )
        episodeTopConstraint = episodeCollectionView.topAnchor.constraint(
            equalTo: languageStackView.bottomAnchor,
            constant: 12
        )
        descriptionBottomConstraint = descriptionToggleButton.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -20
        )
        
        episodeLanguageTopConstraint = languageStackView.topAnchor.constraint(
            equalTo: descriptionToggleButton.bottomAnchor,
            constant: 12
        )
        NSLayoutConstraint.activate([

            // Back Button
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            // Landscape Back Button
            landscapeBackButton.leadingAnchor.constraint(
                equalTo: playerView.leadingAnchor,
                constant: 20
            ),
            landscapeBackButton.topAnchor.constraint(
                equalTo: playerView.topAnchor,
                constant: 20
            ),
            landscapeBackButton.widthAnchor.constraint(equalToConstant: 40),
            landscapeBackButton.heightAnchor.constraint(equalToConstant: 40),

            // Landscape Title
            landscapeTitleLabel.centerYAnchor.constraint(
                equalTo: landscapeBackButton.centerYAnchor
            ),
            landscapeTitleLabel.leadingAnchor.constraint(
                equalTo: landscapeBackButton.trailingAnchor,
                constant: 10
            ),
            landscapeTitleLabel.trailingAnchor.constraint(
                equalTo: playerView.trailingAnchor,
                constant: -20
            ),

            // Header Title
            headerTitlelabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),
            headerTitlelabel.leadingAnchor.constraint(
                equalTo: backButton.trailingAnchor,
                constant: 10
            ),
            headerTitlelabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            // Quality Button
            qualityButton.topAnchor.constraint(
                equalTo: playerView.topAnchor,
                constant: 12
            ),
            qualityButton.trailingAnchor.constraint(
                equalTo: playerView.trailingAnchor,
                constant: -10
            ),
            qualityButton.widthAnchor.constraint(equalToConstant: 40),
            qualityButton.heightAnchor.constraint(equalToConstant: 40),

            // Playback Speed Button
            playbackSpeedButton.topAnchor.constraint(
                equalTo: playerView.topAnchor,
                constant: 12
            ),
            playbackSpeedButton.trailingAnchor.constraint(
                equalTo: qualityButton.leadingAnchor,
                constant: -10
            ),
            playbackSpeedButton.widthAnchor.constraint(equalToConstant: 40),
            playbackSpeedButton.heightAnchor.constraint(equalToConstant: 40),

            // Poster
            posterImageView.topAnchor.constraint(
                equalTo: headerTitlelabel.bottomAnchor,
                constant: 15
            ),
            posterImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            posterImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            posterImageView.heightAnchor.constraint(
                equalTo: posterImageView.widthAnchor,
                multiplier: 9.0 / 16.0
            ),

            // Player
            playerView.topAnchor.constraint(
                equalTo: headerTitlelabel.bottomAnchor,
                constant: 15
            ),
            playerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            playerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            playerView.heightAnchor.constraint(
                equalTo: playerView.widthAnchor,
                multiplier: 9.0 / 16.0
            ),

            // Play/Pause
            playPauseButton.centerXAnchor.constraint(
                equalTo: playerView.centerXAnchor
            ),
            playPauseButton.centerYAnchor.constraint(
                equalTo: playerView.centerYAnchor
            ),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),

            // Backward
            backwardButton.centerXAnchor.constraint(
                equalTo: playerView.centerXAnchor,
                constant: -70
            ),
            backwardButton.centerYAnchor.constraint(
                equalTo: playerView.centerYAnchor
            ),
            backwardButton.widthAnchor.constraint(equalToConstant: 50),
            backwardButton.heightAnchor.constraint(equalToConstant: 50),

            // Forward
            forwardButton.centerXAnchor.constraint(
                equalTo: playerView.centerXAnchor,
                constant: 70
            ),
            forwardButton.centerYAnchor.constraint(
                equalTo: playerView.centerYAnchor
            ),
            forwardButton.widthAnchor.constraint(equalToConstant: 50),
            forwardButton.heightAnchor.constraint(equalToConstant: 50),

            // Progress Slider
            progressSlider.bottomAnchor.constraint(
                equalTo: playerView.bottomAnchor,
                constant: -10
            ),
            progressSlider.heightAnchor.constraint(equalToConstant: 20),

            // Current Time
            currentTimeLabel.leadingAnchor.constraint(
                equalTo: playerView.leadingAnchor,
                constant: 10
            ),
            currentTimeLabel.bottomAnchor.constraint(
                equalTo: playerView.bottomAnchor,
                constant: -10
            ),

            // Duration
            durationlabel.trailingAnchor.constraint(
                equalTo: fullscreenButton.leadingAnchor,
                constant: -8
            ),
            durationlabel.bottomAnchor.constraint(
                equalTo: playerView.bottomAnchor,
                constant: -10
            ),

            // Progress Slider Horizontal
            progressSlider.leadingAnchor.constraint(
                equalTo: currentTimeLabel.trailingAnchor,
                constant: 8
            ),
            progressSlider.trailingAnchor.constraint(
                equalTo: durationlabel.leadingAnchor,
                constant: -8
            ),
            progressSlider.centerYAnchor.constraint(
                equalTo: currentTimeLabel.centerYAnchor
            ),

            // Fullscreen
            fullscreenButton.leadingAnchor.constraint(
                equalTo: durationlabel.trailingAnchor,
                constant: 8
            ),
            fullscreenButton.centerYAnchor.constraint(
                equalTo: durationlabel.centerYAnchor
            ),
            fullscreenButton.widthAnchor.constraint(equalToConstant: 30),
            fullscreenButton.heightAnchor.constraint(equalToConstant: 30),
            fullscreenButton.trailingAnchor.constraint(
                equalTo: playerView.trailingAnchor,
                constant: -10
            ),

            // Buffering Indicator
            bufferingIndicator.centerXAnchor.constraint(
                equalTo: playerView.centerXAnchor
            ),
            bufferingIndicator.centerYAnchor.constraint(
                equalTo: playerView.centerYAnchor
            ),

            // Scroll View
            scrollView.topAnchor.constraint(
                equalTo: playerView.bottomAnchor,
                constant: 8
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            // Content View
            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            // Movie Title
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 20
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Genre
            genreLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            genreLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            genreLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Watch Now
            watchNowButton.topAnchor.constraint(
                equalTo: genreLabel.bottomAnchor,
                constant: 18
            ),
            watchNowButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            watchNowButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            watchNowButton.heightAnchor.constraint(equalToConstant: 50),

            // Action Stack View
            actionStackView.topAnchor.constraint(
                equalTo: watchNowButton.bottomAnchor,
                constant: 28
            ),
            actionStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),
            actionStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            // Language Stack View
            languageStackTopConstraint,
            languageStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            languageStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            languageStackHeightConstraint,

            // Description
            descriptionTopConstraint,
            descriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Description Toggle
            descriptionToggleButton.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: 8
            ),
            descriptionToggleButton.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            // Recommended Title
            recommendedTitlelabel.topAnchor.constraint(
                equalTo: descriptionToggleButton.bottomAnchor,
                constant: 12
            ),
            recommendedTitlelabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            recommendedTitlelabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            // Recommended Collection
            recommendedCollectionView.topAnchor.constraint(
                equalTo: recommendedTitlelabel.bottomAnchor,
                constant: 8
            ),
            recommendedCollectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            recommendedCollectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            recommendedCollectionView.heightAnchor.constraint(
                equalToConstant: 190
            ),
            // Episode Collection
            episodeTopConstraint,
            episodeCollectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            episodeCollectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            episodeCollectionView.heightAnchor.constraint(
                equalToConstant: 380
            )
        ])


        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        genreLabel.font = .systemFont(ofSize: 16)
        genreLabel.textColor = .lightGray
        genreLabel.numberOfLines = 1
        
        
        languageStackView.axis = .horizontal
        languageStackView.spacing = 10
        languageStackView.alignment = .center
        languageStackView.distribution = .fillEqually
        
        watchNowButton.setTitle("WATCH NOW", for: .normal)
        watchNowButton.setTitleColor(.black, for: .normal)
        watchNowButton.backgroundColor = .systemGreen
        watchNowButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        watchNowButton.layer.cornerRadius = 8
        
        watchNowButton.addTarget(self, action: #selector(watchNowButtonTapped), for: .touchUpInside)
        
        let downloadButton = createActionButton(title: "Download", imageName: "arrow.down.circle")
        
        let previewButton = createActionButton(title: "Preview", imageName: "play.rectangle")
        
        let addButton = createActionButton(title: "Add to List", imageName: "plus.circle")
        
        let shareButton = createActionButton(title: "Share", imageName: "square.and.arrow.up")
        
        let likeButton = createActionButton(title: "Like", imageName: "heart")
        
        actionStackView.axis = .horizontal
        actionStackView.alignment = .center
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 8
        
        actionStackView.addArrangedSubview(downloadButton)
        actionStackView.addArrangedSubview(previewButton)
        actionStackView.addArrangedSubview(addButton)
        actionStackView.addArrangedSubview(shareButton)
        actionStackView.addArrangedSubview(likeButton)

        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 3
        
        descriptionToggleButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        descriptionToggleButton.tintColor = .systemGreen
        descriptionToggleButton.addTarget(self, action: #selector(descriptionToggleTapped), for: .touchUpInside)
        descriptionToggleButton.isHidden = true

        contentView.backgroundColor = .black

        backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
        landscapeBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        landscapeBackButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        landscapeBackButton.tintColor = .white
        
        landscapeTitleLabel.textColor = .white
        landscapeTitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        landscapeTitleLabel.numberOfLines = 1
        
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        playPauseButton.tintColor = .white
        
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
        backwardButton.setImage(UIImage(systemName:"gobackward.15"), for: .normal)
        backwardButton.tintColor = .white
        
        backwardButton.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        
        forwardButton.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        forwardButton.tintColor = .white
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.value = 0
        
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        
        progressSlider.addTarget(self, action: #selector(progressSliderTouchEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        currentTimeLabel.text = "00:00"
        durationlabel.text = "00:00"
        
        currentTimeLabel.textColor = .white
        durationlabel.textColor = .white
        
        currentTimeLabel.font = .systemFont(ofSize: 12)
        durationlabel.font = .systemFont(ofSize: 12)
        
        fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        fullscreenButton.tintColor = .white
        fullscreenButton.addTarget(
            self,
            action: #selector(fullscreenButtonTapped),
            for: .touchUpInside
        )
        
        qualityButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        qualityButton.tintColor = .white
        qualityButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        qualityButton.layer.cornerRadius = 20
        
        configureQualityMenu()
        qualityButton.showsMenuAsPrimaryAction = true
        
        playbackSpeedButton.setImage(UIImage(systemName: "speedometer"), for: .normal)
        playbackSpeedButton.tintColor = .white
        playbackSpeedButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        playbackSpeedButton.layer.cornerRadius = 20
        configurePlaybackSpeedmenu()
        
        recommendedCollectionView.backgroundColor = .clear
        recommendedCollectionView.showsHorizontalScrollIndicator = false
        
        recommendedCollectionView.register(HomeContentCollectionViewCell.self, forCellWithReuseIdentifier: "RecommendedCell")
        
        recommendedCollectionView.dataSource = self
        recommendedCollectionView.delegate = self
        
        recommendedTitlelabel.text = "Recommended"
        recommendedTitlelabel.textColor = .white
        recommendedTitlelabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        episodeCollectionView.backgroundColor = .clear
        episodeCollectionView.showsVerticalScrollIndicator = false
        episodeCollectionView.register(EpisodeCollectionViewCell.self, forCellWithReuseIdentifier: "EpisodeCell")
        
        episodeCollectionView.dataSource = self
        episodeCollectionView.delegate = self
        
        updateOrientationUI(isLandscape: false)
    }
    
    private func setupLanguages() {

        // Remove existing language buttons
        languageStackView.arrangedSubviews.forEach {
            languageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // Use parent show details for an episode
        let details = viewModel.detailsType == .episode
            ? viewModel.parentShowDetails
            : viewModel.movieDetails
        
        print("===== EPISODE LANGUAGE DEBUG =====")
        print("Details Type:", viewModel.detailsType)
        print("Parent Show Details:", viewModel.parentShowDetails != nil)
        print("Parent Subcategories Count:", viewModel.parentShowDetails?.subcategories?.count ?? 0)

        let subcategories = details?.subcategories?.filter {
            $0.episodeFlag == "yes" &&
            ($0.episodeCount ?? 0) > 0
        } ?? []
        
        print("Filtered Language Count:", subcategories.count)

        for subcategory in subcategories {
            print(
                "Language:",
                subcategory.title ?? "",
                "ContentID:",
                subcategory.contentID ?? "",
                "EpisodeFlag:",
                subcategory.episodeFlag ?? "",
                "EpisodeCount:",
                subcategory.episodeCount ?? 0
            )
        }

        // Create button for each language
        for subcategory in subcategories {

            guard let title = subcategory.title else {
                continue
            }

            let button = UIButton(type: .system)

            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .darkGray
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(
                ofSize: 14,
                weight: .medium
            )

            button.tag = subcategory.sequenceNo ?? 0

            button.addTarget(
                self,
                action: #selector(languageButtonTapped),
                for: .touchUpInside
            )

            languageStackView.addArrangedSubview(button)
        }

        guard let selectedContentID = viewModel.selectedLanguageContentID
                ?? subcategories.first?.contentID else {
            return
        }

        Task {
            await viewModel.fetchEpisodes(
                subcategoryID: selectedContentID
            )

            await MainActor.run {
                self.episodeCollectionView.reloadData()
            }
        }
    }
    
    private func showPoster(for details: MovieDetails) {

        playerView.isHidden = true
        posterImageView.isHidden = false
        
        posterImageView.image = UIImage(named: "imagePlaceholder16x9")

        guard let imageURLString = details.thumbnails?.large16_9?.url,
              let imageURL = URL(string: imageURLString) else {
            return
        }

        Task {
            do {
                let image = try await viewModel.fetchImage(from: imageURL)

                await MainActor.run {
                    self.posterImageView.image = image
                }
            } catch {
                print("Poster image loading failed:", error)
            }
        }
    }
   
    private func setupPlayer(with url: URL) {
        print("PlayerURL", url.absoluteString)

        let item = AVPlayerItem(url: url)
        self.playerItem = item

        if let player {
            player.replaceCurrentItem(with: playerItem)
            player.play()
            return
        }
        player = AVPlayer(playerItem: playerItem)

        bufferingIndicator.startAnimating()

        addTimeObserver()

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect

        if let playerLayer {
            playerView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.frame = playerView.bounds
        }

        item.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new, .initial],
            context: nil
        )
        
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.new, .initial], context: nil)
        
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new, .initial] , context: nil)

        player?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayer.timeControlStatus),
            options: [.new, .initial],
            context: nil
        )

        player?.play()
    }
    
    private func selectQuality(_ quality: VideoQuality) {
        guard playerItem != nil else {
            return
        }

        if quality == .auto {
            selectedQuality = .auto
            playerItem?.preferredMaximumResolution = .zero
            configureQualityMenu()
            
            print("Quality: Auto")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                   self?.printCurrentHLSBitrate()
               }
            return
        }

        guard let variant = variant(for: quality, from: hlsVariants) else {
            print("Variant not found for:", quality)
            return
        }
        
        selectedQuality = quality

        let resolution = variant.videoAttributes?.presentationSize ?? .zero

        playerItem?.preferredMaximumResolution = resolution
        
        configureQualityMenu()

        print("Selected quality:", quality)
        print("Preferred resolution:", resolution)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.printCurrentHLSBitrate()
        }
    }
    
    private func printCurrentHLSBitrate() {
        guard let event = playerItem?.accessLog()?.events.last else {
            print("No HLS access log available")
            return
        }

        print("Indicated bitrate:", event.indicatedBitrate)
        print("Observed bitrate:", event.observedBitrate)
        print("Switch bitrate:", event.switchBitrate)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = playerView.bounds
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(AVPlayerItem.status),
           let playerItem = object as? AVPlayerItem {

            switch playerItem.status {
            case .readyToPlay:
                print(" Video READY TO PLAY")

            case .failed:
                bufferingIndicator.stopAnimating()
                print("Video FAILED")
                print("Error:", playerItem.error as Any)

            case .unknown:
                print("Video status UNKNOWN")

            @unknown default:
                break
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
           let playerItem = object as? AVPlayerItem {
            
            if playerItem.isPlaybackBufferEmpty {
                print("Buffer is empty")
            } else {
                print("Buffer has data")
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), let playerItem = object as? AVPlayerItem {
            if playerItem.isPlaybackLikelyToKeepUp {
                print("Likely to keep playing")
            } else {
                print("Not likely to keep playing")
            }
            
            if let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue {
                let start = CMTimeGetSeconds(timeRange.duration)
                let duration = CMTimeGetSeconds(timeRange.duration)
                let currentTime = CMTimeGetSeconds(playerItem.currentTime())

                let bufferedEnd = start + duration

                let bufferedSeconds = bufferedEnd - currentTime

                print("Buffered start:", start)
                print("Buffered duration:", duration)
                print("Current time:", currentTime)
                print("Buffered end:", bufferedEnd)
                print("Buffered seconds ahead:", bufferedSeconds)
            }
        }

        if keyPath == #keyPath(AVPlayer.timeControlStatus),
           let player = object as? AVPlayer {

            switch player.timeControlStatus {
            case .playing:
                bufferingIndicator.stopAnimating()
                print("Player PLAYING")

            case .paused:
                bufferingIndicator.stopAnimating()
                print("Player PAUSED")

            case .waitingToPlayAtSpecifiedRate:
                bufferingIndicator.startAnimating()
                print("Player Buffering")
                
                if let reason = player.reasonForWaitingToPlay {
                    print("Waiting reason:", reason)
                }

            @unknown default:
                break
            }
        }
    }
 
    private func createActionButton(title: String, imageName: String) -> UIStackView {
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .lightGray
        
        let label = UILabel()
        label.text = title
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 1
        
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        
        return stack
    }
    
    private func updateDescriptionToggle() {
        guard let text = descriptionLabel.text, !text.isEmpty,
        descriptionLabel.bounds.width > 0 else {
            return
        } //description exits, not empty, label valid width
        
        let fullHeight = text.boundingRect(with: CGSize(width: descriptionLabel.bounds.width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading] , attributes: [.font: descriptionLabel.font as Any], context: nil).height
        
        let threeLineHeight = descriptionLabel.font.lineHeight * 3
        
        descriptionToggleButton.isHidden = fullHeight <= threeLineHeight + 1
        
        view.layoutIfNeeded()
        
    }
    
    private func addTimeObserver() {
        guard let player else {
            return
        }
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            
            guard let self else {
                return
            }
            
            let currentSeconds = CMTimeGetSeconds(time)
            
            guard currentSeconds.isFinite else {
                return
            }
            
            self.currentTimeLabel.text = self.formatTime(seconds: currentSeconds)
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                if durationSeconds.isFinite && durationSeconds > 0 {
                    self.durationlabel.text = self.formatTime(seconds: durationSeconds)
                    self.progressSlider.value = Float(currentSeconds / durationSeconds)
                }
            }
        }
    }
    
    private func formatTime(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscape]
    }
    
    
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func descriptionToggleTapped() {
        let isExpanded = descriptionLabel.numberOfLines == 0
        
        descriptionLabel.numberOfLines = isExpanded ? 3 : 0
        
        descriptionToggleButton.setImage(UIImage(systemName: isExpanded ? "chevron.down" : "chevron.up"), for: .normal)
        
        view.layoutIfNeeded()
        
    }
    
    @objc private func playPauseButtonTapped() {
        guard let player else {
            return
        }
        
        if player.timeControlStatus == .playing {
            player.pause()
            
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            
            player.rate = selectedPlaybackSpeed.rate
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc private func backwardButtonTapped() {
        guard let player else {
            return
        }
        
        let currentTime = player.currentTime()
        
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 15, preferredTimescale: 600))
        player.seek(to: newTime)
    }
    
    @objc private func forwardButtonTapped() {
        guard let player else {
            return
        }
        
        let currentTime = player.currentTime()
        
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 15, preferredTimescale: 600))
        
        player.seek(to: newTime)
    }
    
    @objc private func progressSliderChanged() {
        guard let player,
              let duration = player.currentItem?.duration else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(duration)
        
        guard durationSeconds.isFinite else {
            return
        }
        
        let newTime = Double(progressSlider.value) * durationSeconds
        
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
    
    @objc private func progressSliderTouchEnded() {
        progressSliderChanged()
    }
    
    @objc private func fullscreenButtonTapped() {
        isFullscreen.toggle()
        
        guard let windowScene = view.window?.windowScene else {
            return
        }
        
        if isFullscreen {
            updateOrientationUI(isLandscape: true)
            
            tabBarController?.tabBar.isHidden = true
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        } else {
            updateOrientationUI(isLandscape: false)
            tabBarController?.tabBar.isHidden = false
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
    
    @objc private func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation

        guard let windowScene = view.window?.windowScene else {
            return
        }

        switch orientation {
        case .portrait:
            updateOrientationUI(isLandscape: false)
            
            tabBarController?.tabBar.isHidden = false
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))

        case .landscapeLeft, .landscapeRight:
            updateOrientationUI(isLandscape: true)
            
            tabBarController?.tabBar.isHidden = true
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))

        case .portraitUpsideDown:
            print("PORTRAIT UPSIDE DOWN")

        case .faceUp, .faceDown, .unknown:
            print("OTHER")

        @unknown default:
            print("UNKNOWN FUTURE ORIENTATION")
        }
    }
    
    @objc private func languageButtonTapped(_ sender: UIButton) {

        let details = viewModel.detailsType == .episode
            ? viewModel.parentShowDetails
            : viewModel.movieDetails

        let subcategories = details?.subcategories ?? []
        print("===== LANGUAGE BUTTON =====")
        print("Tapped button:", sender.title(for: .normal) ?? "")
        print("Tapped tag:", sender.tag)

        for subcategory in subcategories {
            print(
                "Language:",
                subcategory.title ?? "",
                "Sequence:",
                subcategory.sequenceNo ?? 0,
                "Content ID:",
                subcategory.contentID ?? ""
            )
        }


        guard let selected = subcategories.first(
            where: { $0.sequenceNo == sender.tag }
        ) else {
            return
        }

        print("Selected Language:", selected.title ?? "")
        print("Catalog ID:", selected.catalogID ?? "")
        print("Content ID:", selected.contentID ?? "")
        print("Language Code:", selected.language ?? "")
        print("Episode Count:", selected.episodeCount ?? 0)

        Task {

            await viewModel.fetchEpisodes(
                subcategoryID: selected.contentID ?? ""
            )

            await MainActor.run {
                self.episodeCollectionView.reloadData()
            }
        }
    }
    
    private func updateOrientationUI(isLandscape: Bool) {
        backButton.isHidden = isLandscape
        headerTitlelabel.isHidden = isLandscape
        
        landscapeBackButton.isHidden = !isLandscape
        landscapeTitleLabel.isHidden = !isLandscape
    }
    
    @objc private func watchNowButtonTapped() {
        guard let userDetails = viewModel.userDetails else {
            print("Get All Details not available")
            return
        }

        guard let playURLString = userDetails.adaptiveURL,
              let playURL = URL(string: playURLString) else {
            print("Adaptive URL not available")
            return
        }

        print("Watch Now URL:", playURL)
        inspectHLSAssest(url: playURL)
        setupPlayer(with: playURL)
    }
 
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension MovieDetailsViewController:
    MovieDetailsViewModelDelegate {
    func didUpdateRecommendedItems() {
        print("Recommended items received")
        
        recommendedCollectionView.reloadData()
    }
}

extension MovieDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == recommendedCollectionView {
            return viewModel.recommendedItems.count
        }
        
        if collectionView == episodeCollectionView {
            return viewModel.episodes.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == episodeCollectionView {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as? EpisodeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let episode = viewModel.episodes[indexPath.item]
            
            cell.configure(with: episode,
            fetchImage: { [weak self] url in
                guard let self else {
                    throw APIError.invalidResponse
                }
                return try await self.viewModel.fetchImage(from: url)
            }
        )

             return cell
            
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as? HomeContentCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.recommendedItems[indexPath.item]
        
        cell.configure(with: item, layoutType: "t_2_3_movie", fetchImage: { [weak self] url in
            guard let self else {
                throw APIError.invalidResponse
            }
            return try await self.viewModel.fetchImage(from: url)
        })
        
        return cell
    }

}

extension MovieDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        if collectionView == episodeCollectionView {
            return CGSize(width: collectionView.bounds.width, height: 160)
        }

        let width = collectionView.bounds.width * 0.27
        let imageHeight = width * 3.0 / 2.0

        let titleFont = UIFont.systemFont(
            ofSize: 16,
            weight: .medium
        )

        let titleHeight = titleFont.lineHeight * 2

        let height = imageHeight + titleHeight

        return CGSize(
            width: width,
            height: height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard collectionView == episodeCollectionView else {
            return
        }

        let episode = viewModel.episodes[indexPath.item]

        print("Selected Episode:", episode.title ?? "")
        print("Catalog ID:", episode.catalogID ?? "")
        print("Content ID:", episode.contentID ?? "")
        
        print("===== PASSING SHOW DETAILS TO EPISODE =====")
        print("Show Details Exists:", viewModel.movieDetails != nil)
        print("Show Subcategories:", viewModel.movieDetails?.subcategories?.count ?? 0)

        let parentDetails = viewModel.detailsType == .episode
            ? viewModel.parentShowDetails
            : viewModel.movieDetails
        
        let episodeViewModel = MovieDetailsViewModel(
            catalogId: episode.catalogID ?? "",
            contentId: episode.contentID ?? "",
            isEpisode: true,
            episode: episode,
            parentShowDetails: parentDetails,
            selectedLanguageContentID: viewModel.selectedLanguageContentID
        )

        let episodeDetailsViewController = MovieDetailsViewController(
            viewModel: episodeViewModel
        )

        navigationController?.pushViewController(
            episodeDetailsViewController,
            animated: true
        )
    }
    
}
