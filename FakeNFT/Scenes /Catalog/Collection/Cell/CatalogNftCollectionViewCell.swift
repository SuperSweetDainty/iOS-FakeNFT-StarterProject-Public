//
//  CatalogNftCollectionViewCell.swift
//  FakeNFT
//
//  Created by Irina Gubina on 13.10.2025.
//

import UIKit
import Kingfisher

final class CatalogNftCollectionViewCell: UICollectionViewCell {
    // MARK: - Static Properties
    static let identifier = "CatalogNFTCollectionViewCell"
    
    var onFavoriteButtonTapped: (() -> Void)?
    var onCartButtonTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var favoriteNftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nameNftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var priceNftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var nft: NftCellModel?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        nameNftLabel.text = nil
        priceNftLabel.text = nil
        clearRating()
        onFavoriteButtonTapped = nil
    }
    // MARK: - IB Actions
    @objc private func favoriteButtonTapped() {
        onFavoriteButtonTapped?()
    }
    
    @objc private func cartButtonTapped() {
        onCartButtonTapped?()
    }
    
    // MARK: - Public Methods
    func configure(with nft: NftCellModel) {
        self.nft = nft
        let capitalizedDescription = nft.name.prefix(1).uppercased() + nft.name.dropFirst()
        nameNftLabel.text = capitalizedDescription
        priceNftLabel.text = "\(nft.price) ETH"
        
        // Настраиваем кнопки
        setFavoriteNftButtonImage(isFavorite: nft.isFavorite)
        setCartButtonImage(isInCart: nft.isInCart)
        
        // Настраиваем рейтинг
        setupRating(rating: nft.rating)
        
        // Загрузка изображения
        if !nft.images.isEmpty,
           let url = URL(string: nft.images) {
            nftImageView.kf.setImage(with: url)
        } else {
            nftImageView.image = UIImage(systemName: "photo.on.rectangle")?
                .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        }
    }
    
    func setCartButtonImage(isInCart: Bool) {
        let imageName = isInCart ? "cart_on" : "cart_off"
        cartButton.setImage(UIImage(named: imageName), for: .normal)
        cartButton.accessibilityIdentifier = isInCart ? "cart_on" : "cart_off"
    }
    
    func setFavoriteNftButtonImage(isFavorite: Bool) {
        let imageName = isFavorite ? "like_on" : "like_off"
        favoriteNftButton.setImage(UIImage(named: imageName), for: .normal)
        favoriteNftButton.accessibilityIdentifier = isFavorite ? "like_on" : "like_off"
    }
    
    //MARK: - Private Methods
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        [nftImageView, favoriteNftButton, ratingStackView, nameNftLabel, priceNftLabel, cartButton].forEach{ contentView.addSubview($0)}
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //  Nft ImageView
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            //Favorite Nft Button
            favoriteNftButton.heightAnchor.constraint(equalToConstant: 42),
            favoriteNftButton.widthAnchor.constraint(equalToConstant: 42),
            favoriteNftButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            favoriteNftButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            
            //Rating StackView
            ratingStackView.widthAnchor.constraint(equalToConstant: 68),
            ratingStackView.heightAnchor.constraint(equalToConstant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            
            //Name Nft Label
            nameNftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameNftLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 4),
            nameNftLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor),
            
            //Price Nft Label
            priceNftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceNftLabel.topAnchor.constraint(equalTo: nameNftLabel.bottomAnchor, constant: 4),
            
            //Cart Button
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupRating(rating: Int) {
        clearRating()
        
        for i in 0..<5 {
            let starImageView = UIImageView()
            if i < rating {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .systemGray4
            }
            starImageView.contentMode = .scaleAspectFit
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
    
    private func clearRating() {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
