import UIKit

final class HomeSectionTableViewCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let arrowButton = UIButton(type: .system)
    private let collectionView: UICollectionView

    //Data Properties
    private var items: [HomeItem] = []
    private var layoutType: String?
    private var viewModel: HomeViewModel!

    
    var onArrowTapped: (() -> Void)? //closure

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
        
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        arrowButton.tintColor = .systemGreen
        
        arrowButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)

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
        contentView.addSubview(arrowButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: arrowButton.leadingAnchor,
                constant: -10
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 10
            ),
            
            arrowButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            arrowButton.centerYAnchor.constraint(
                equalTo: titleLabel.centerYAnchor
            ),

            arrowButton.widthAnchor.constraint(
                equalToConstant: 40
            ),

            arrowButton.heightAnchor.constraint(
                equalToConstant: 40
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
    
    @objc private func arrowButtonTapped() {
        print("Arrow Button Tapped")
        onArrowTapped?()
    }

    func configure(
        with section: HomeSection,
        viewModel: HomeViewModel,
        onArrowTapped: @escaping () -> Void
    ) {
        self.viewModel = viewModel

        titleLabel.text = section.displayTitle
        items = section.catalogListItems ?? []
        
        layoutType = section.catalogListItems?.first?.catalogObject?.layoutType
        
        self.onArrowTapped = onArrowTapped //store
        
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

        let titleHeight = UIFont.systemFont(
            ofSize: 14,
            weight: .medium
        ).lineHeight

        let spacing = titleHeight * 0.5

        let cellHeight = imageHeight + spacing + titleHeight


        return CGSize(
            width: width,
            height: cellHeight
        )
    }
    
}
