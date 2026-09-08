//
//  MoreTableViewCell.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 03/09/26.
//

import UIKit

final class MoreTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageview = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        iconImageView.tintColor = .gray
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        arrowImageview.image = UIImage(systemName: "chevron.right")
        arrowImageview.tintColor = .systemGreen
        arrowImageview.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageview)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 25
            ),
            iconImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 25
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: arrowImageview.leadingAnchor,
                constant: -20
            ),

            arrowImageview.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -25
            ),
            arrowImageview.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }
    
    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
    }
    
}
