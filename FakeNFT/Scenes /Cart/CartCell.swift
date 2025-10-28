//
//  CartCell.swift
//  FakeNFT
//
//  Created by R Kolos on 5/10/25.
//

import UIKit

final class CartCell: UITableViewCell {
    
    static let reuseIdentifier = "CartCell"
    
    private(set) var id: String?
    private var delegate: CellCartProtocol?
    
    private var emptyView = UIView()
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textActive
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textActive
        return label
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Цена"
        label.font = .caption2
        label.textColor = .textActive
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let image = UIImage(resource: .cart)
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(Self.didTapDeleteButton), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.tintColor = .segmentActive
        return button
    }()
    
    private let starImageViews: [UIImageView] = (0..<5).map { _ in
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .star).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .segmentInactive
        return imageView
    }
    
    private lazy var starsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: starImageViews)
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
        setupConstraints()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
        setupConstraints()
    }
    
    func setupCell(with nft: Nft, delegate: CellCartProtocol) {
        self.delegate = delegate
        id = nft.id
        let nftDisplayName = extractNFTName(from: nft.images.first?.absoluteString ?? "")
        nameLabel.text = nftDisplayName.capitalized
        priceLabel.text = "\(nft.price) ETH"
        
        if let firstImageURL = nft.images.first {
            nftImageView.kf.setImage(with: firstImageURL)
        } else {
            nftImageView.image = UIImage(named: "placeholder")
        }
        
        for (index, imageView) in starImageViews.enumerated() {
            let isActive = index < nft.rating && nft.rating > 0
            imageView.tintColor = isActive ? .yellowUniversal : .segmentActive
        }
    }
    
    private func setupSubviews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emptyView)
        emptyView.addSubview(nftImageView)
        emptyView.addSubview(nameLabel)
        emptyView.addSubview(priceLabel)
        emptyView.addSubview(priceTitleLabel)
        emptyView.addSubview(deleteButton)
        emptyView.addSubview(starsStackView)
    }
    
    private func setupConstraints() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 16),
            emptyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -16),
            emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            
            nftImageView.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            nftImageView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            
            nameLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            starsStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            starsStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor,constant: 20),
            
            priceTitleLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 12),
            priceTitleLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor,constant: 20),
            
            priceLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor,constant: 20),
            
            deleteButton.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
    }
    
    private func extractNFTName(from imageURL: String?) -> String {
        guard let imageURL = imageURL,
              let _ = URL(string: imageURL) else { return "NFT" }
        
        let components = imageURL.components(separatedBy: "/")
        
        if let nftIndex = components.firstIndex(of: "NFT"),
           nftIndex + 2 < components.count {
            _ = components[nftIndex + 1]
            let nftName = components[nftIndex + 2]
            return nftName.capitalized
        }
        
        return "NFT"
    }
    
    @objc private func didTapDeleteButton() {
        guard
            let id,
            let image = nftImageView.image
        else { return }
        delegate?.present(with: id,image: image)
    }
}
