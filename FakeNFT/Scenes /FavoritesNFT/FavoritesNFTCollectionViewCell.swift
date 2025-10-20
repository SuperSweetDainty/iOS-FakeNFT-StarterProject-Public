import UIKit

final class FavoritesNFTCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    
    // MARK: - Properties
    
    private var onLikeTapped: ((Bool) -> Void)?
    private var isLiked: Bool = false
    
    // MARK: - UI Elements
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .background
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .heart), for: .normal)
        button.setImage(UIImage(resource: .heartFill), for: .selected)
        button.tintColor = .white
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .background
        
        [nftImageView, likeButton, containerView].forEach {
            contentView.addSubview($0)
        }
        
        [nameLabel, ratingStackView, priceLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // NFT Image - слева, 80x80
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 80),
            nftImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Like button - на изображении
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 6),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -6),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Container view - справа от изображения с отступом 12, отступы 7 сверху и снизу
            containerView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -7),
            
            // Name label - сверху контейнера, 0 слева
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Rating stack view - ниже названия на 4, 0 слева
            ratingStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            // Price label - ниже рейтинга на 8, 0 слева
            priceLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft, isLiked: Bool, onLikeTapped: @escaping (Bool) -> Void) {
        self.isLiked = isLiked
        self.onLikeTapped = onLikeTapped
        
        nameLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        
        // Set NFT image based on name
        switch nft.name {
        case "Lilo":
            nftImageView.image = UIImage(resource: .lilo)
        case "Spring":
            nftImageView.image = UIImage(resource: .spring)
        case "April":
            nftImageView.image = UIImage(resource: .april)
        case "Pixi":
            nftImageView.image = UIImage(resource: .pixi)
        case "Melissa":
            nftImageView.image = UIImage(resource: .melissa)
        case "Daisy":
            nftImageView.image = UIImage(resource: .daisy)
        case "Archie":
            nftImageView.image = UIImage(resource: .archie)
        default:
            nftImageView.image = UIImage(resource: .lilo)
        }
        
        // Configure like button
        likeButton.isSelected = isLiked
        
        if isLiked {
            likeButton.tintColor = UIColor(hexString: "F56B6C")
        } else {
            likeButton.tintColor = .white
        }
        
        // Configure rating
        setupRatingStars(rating: nft.rating)
    }
    
    private func setupRatingStars(rating: Int) {
        // Clear existing stars
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add stars
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(systemName: i <= rating ? "star.fill" : "star")
            starImageView.tintColor = UIColor(hexString: "FEEF0D")
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: 12),
                starImageView.heightAnchor.constraint(equalToConstant: 12)
            ])
            
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        likeButton.isSelected = isLiked
        
        if isLiked {
            likeButton.tintColor = UIColor(hexString: "F56B6C")
        } else {
            likeButton.tintColor = .white
        }
        
        onLikeTapped?(isLiked)
    }
}

