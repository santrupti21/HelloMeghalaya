import UIKit

final class HomeSliderCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private var imageTask: Task<Void, Never>?

    private let placeholderImage =
        UIImage(named: "imagePlaceholder16x9")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        imageView.backgroundColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

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
        viewModel: HomeViewModel
    ) {

        imageTask?.cancel()

        imageView.image = placeholderImage

        guard
            let imageURLString = item.thumbnails.large16_9?.url,
            let url = URL(string: imageURLString)
        else {
            return
        }

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
                    "Slider image Loading failed:",
                    error
                )
            }
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil

        imageView.image = nil
    }
}
