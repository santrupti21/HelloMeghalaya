//
//  CatalogTabCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 12/08/26.
//

import UIKit

final class CatalogTabCell: UICollectionViewCell {

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        titleLabel.textAlignment = .center

        titleLabel.font = .systemFont(
            ofSize: 18,
            weight: .medium
        )

        titleLabel.textColor = .white

        contentView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }

    func configure(title: String, isSelected: Bool) {

        titleLabel.text = title

        if isSelected {
            
            layer.borderWidth = 2

            layer.borderColor = UIColor.white.cgColor

        } else {

            layer.borderWidth = 0

            layer.borderColor = nil
        }
    }

    override func layoutSubviews() {

        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2
    }
}
