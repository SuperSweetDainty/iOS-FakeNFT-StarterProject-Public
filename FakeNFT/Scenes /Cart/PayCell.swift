//
//  PayCell.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import UIKit
import Kingfisher

final class PayCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier: String = "PayCell"
    
    private lazy var coinImageView: UIImageView = {
        let coinImageView = UIImageView()
        coinImageView.image = UIImage(resource: .placeholder)
        coinImageView.contentMode = .scaleAspectFill
        coinImageView.clipsToBounds = true
        coinImageView.layer.cornerRadius = 6
        coinImageView.backgroundColor = .segmentActive
        return coinImageView
    }()
    
    private lazy var coinTitleLabel: UILabel = {
        let coinTitleLabel = UILabel()
        coinTitleLabel.font = .caption2
        coinTitleLabel.textColor = .textActive
        return coinTitleLabel
    }()
    
    private lazy var coinNameLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .greenUniversal
        return label
    }()
    
    // MARK: - init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupCellView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    // MARK: - Methods
    func setupCell(with coin: Coin) {
        coinNameLabel.text = coin.name
        coinTitleLabel.text = coin.title.replacingOccurrences(of: "_", with: " ")
        coinImageView.kf.setImage(with: coin.image)
    }
    
    func select() {
        contentView.layer.borderWidth = 1
    }
    
    func deselect() {
        contentView.layer.borderWidth = 0
    }
    
    private func setupCellView() {
        contentView.layer.borderColor = UIColor.segmentActive.cgColor
        contentView.backgroundColor = .segmentInactive
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(coinNameLabel)
        contentView.addSubview(coinTitleLabel)
        contentView.addSubview(coinImageView)
        
        coinNameLabel.translatesAutoresizingMaskIntoConstraints = false
        coinTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coinImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 12),
            coinImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            coinImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            coinImageView.widthAnchor.constraint(equalToConstant: 36),
            
            coinTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            coinTitleLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 4),
            
            coinNameLabel.topAnchor.constraint(equalTo: coinTitleLabel.bottomAnchor),
            coinNameLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 4)
        ])
        
    }
}

