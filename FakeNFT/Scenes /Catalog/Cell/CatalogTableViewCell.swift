//
//  CatalogTableViewCell.swift
//  FakeNFT
//
//  Created by Irina Gubina on 06.10.2025.
//

import UIKit
import Kingfisher

class CatalogTableViewCell: UITableViewCell {
    
    //MARK: - Public Properties
    static let reuseIdentifier = "CatalogTableViewCell"
    
    // MARK: - UI Elements
    private lazy var catalogImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        image.backgroundColor = .gray
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        catalogImageView.kf.cancelDownloadTask()
        catalogImageView.image = nil
        nameLabel.text = nil
        nftCountLabel.text = nil
    }
    
    // MARK: - Public Methods
    func configure(with collection: CatalogCollectionNft) {
        let capitalizedDescription = collection.name.prefix(1).uppercased() + collection.name.dropFirst()
        nameLabel.text = capitalizedDescription
        nftCountLabel.text = "(\(collection.nftCount))"
        
        if let imageURLString = collection.imageURL,
           let url = URL(string: imageURLString) {
            catalogImageView.kf.setImage(with: url)
        } else {
            catalogImageView.image = UIImage(systemName: "photo.on.rectangle")?
                .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        }
    }
    
    // MARK: - Public Methods
    private func setupUI(){
        configureView()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView(){
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func addSubviews(){
        [catalogImageView, nameLabel, nftCountLabel].forEach{ contentView.addSubview($0)}
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            //Catalog ImageView
            catalogImageView.heightAnchor.constraint(equalToConstant: 140),
            catalogImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            catalogImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            catalogImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            //Name Label
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: catalogImageView.bottomAnchor, constant: 4),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            //nftCount Label
            nftCountLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            nftCountLabel.topAnchor.constraint(equalTo: catalogImageView.bottomAnchor, constant: 4),
            nftCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}


