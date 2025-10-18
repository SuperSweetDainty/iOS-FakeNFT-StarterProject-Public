//
//  CatalogCollectionSSectionHeaderView.swift
//  FakeNFT
//
//  Created by Irina Gubina on 13.10.2025.
//

import UIKit

final class CatalogCollectionSectionHeaderView: UICollectionReusableView {
    
    // MARK: - Static Properties
    static let identifier = "CatalogCollectionSectionHeaderView"
    
    var onAuthorTap: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var catalogImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        image.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] //только нижние углы
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.headline3
        label.textColor = .textPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var authorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.textColor = .textPrimary
        label.text = "Автор коллекции:"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var authorLinkLabel:  UILabel = {
        let label = UILabel()
        label.font = UIFont.caption1
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption2
        label.textColor = .textPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAuthorInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let targetSize = CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height)
        let size = systemLayoutSizeFitting(targetSize,
                                           withHorizontalFittingPriority: .required,
                                           verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.size.height = size.height
        return layoutAttributes
    }
    
    private func setupUI(){
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        [catalogImageView, nameLabel, authorTitleLabel, authorLinkLabel, descriptionLabel].forEach {addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //Catalog ImageView
            catalogImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            catalogImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            catalogImageView.topAnchor.constraint(equalTo: topAnchor),
            catalogImageView.heightAnchor.constraint(equalToConstant: 310),
            
            //Name Label
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: catalogImageView.bottomAnchor, constant: 16),
            
            //Author Title Label
            authorTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            authorTitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 13),
            
            
            //Author Link Label
            authorLinkLabel.leadingAnchor.constraint(equalTo: authorTitleLabel.trailingAnchor, constant: 4),
            authorLinkLabel.centerYAnchor.constraint(equalTo: authorTitleLabel.centerYAnchor),
            
            //Description Label
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            descriptionLabel.topAnchor.constraint(equalTo: authorTitleLabel.bottomAnchor, constant: 5),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupAuthorInteraction() {
        let authorTap = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLinkLabel.addGestureRecognizer(authorTap)
    }
    
    @objc private func authorLabelTapped() {
        // Анимация для обратной связи
        UIView.animate(withDuration: 0.1, animations: {
            self.authorLinkLabel.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.authorLinkLabel.alpha = 1.0
            }
        }
        
        onAuthorTap?()
    }
    
    
    func configure(with collection: CatalogCollectionNft) {
        nameLabel.text = collection.name
        if let imageURL = collection.imageURL,
           let image = UIImage(named: imageURL) {
            catalogImageView.image = image
        } else {
            catalogImageView.image = UIImage(systemName: "photo.on.rectangle")?
                .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        }
        
        // TODO: Добавить остальные данные, когда будут в модели
        descriptionLabel.text = "Описание будет позже. Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей."
        authorLinkLabel.text = "John Doe"
        
    }
}
