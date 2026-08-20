import UIKit

final class HomeSectionTableViewCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let collectionView: UICollectionView

    private var items: [HomeItem] = []
    private var layoutType: String?
    private var viewModel: HomeViewModel!
    

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(
            ofSize: 20,
            weight: .semibold
        )

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(
            HomeContentCollectionViewCell.self,
            forCellWithReuseIdentifier: "HomeContentCell"
        )

        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 10
            ),

            titleLabel.heightAnchor.constraint(
                equalToConstant: 30
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            collectionView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 10
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -10
            )
        ])
    }

    func configure(
        with section: HomeSection,
        viewModel: HomeViewModel
    ) {
        self.viewModel = viewModel

        titleLabel.text = section.displayTitle
        items = section.catalogListItems ?? []

        if section.displayTitle == "Snippets" {
            layoutType = "t_2_3_movie"
        } else {
            layoutType = section.catalogObject?.layoutType ?? "16:9"
        }

        collectionView.reloadData()
    }
   
}

extension HomeSectionTableViewCell: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HomeContentCell",
            for: indexPath
        ) as? HomeContentCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]

        cell.configure(
            with: item,
            layoutType: layoutType,
            viewModel: viewModel
        )

        return cell
    }
    
}

extension HomeSectionTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = collectionView.bounds.width * 0.55

        let imageHeight: CGFloat

        if layoutType == "t_2_3_movie" {
            imageHeight = width * 3.0 / 2.0
        } else {
            imageHeight = width * 9.0 / 16.0
        }

        let titleHeight: CGFloat = 40
        let spacing: CGFloat = 8

        return CGSize(
            width: width,
            height: imageHeight + spacing + titleHeight - 1
        )
    }
}
