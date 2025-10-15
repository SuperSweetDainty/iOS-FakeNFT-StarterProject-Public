import UIKit
import Kingfisher

final class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .bodyRegular
        button.setTitleColor(.primary, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    
    // MARK: - Properties
    
    private var onWebsiteTap: (() -> Void)?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .background
        
        [avatarImageView, nameLabel, descriptionLabel, websiteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // MARK: - Avatar (иконка) - крепится к safe area с отступом 20 сверху
            avatarImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // MARK: - Name Label (текст)
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // MARK: - Description Label (текст описания)
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // MARK: - Website Button
            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            websiteButton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            
            // MARK: - Bottom constraint (чтобы tableView знал высоту ячейки)
            websiteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupActions() {
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func websiteButtonTapped() {
        onWebsiteTap?()
    }
    
    // MARK: - Configuration
    
    func configure(with user: User, onWebsiteTap: @escaping () -> Void) {
        self.onWebsiteTap = onWebsiteTap
        
        nameLabel.text = user.name
        descriptionLabel.text = user.description
        
        if let avatarURL = user.avatar {
            avatarImageView.kf.setImage(with: avatarURL)
        } else {
            // Set system icon directly without clearing Kingfisher
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
            avatarImageView.backgroundColor = .clear
            
            print("DEBUG: Setting system icon directly")
        }
        
        if let website = user.website {
            websiteButton.setTitle(website.absoluteString, for: .normal)
            websiteButton.isHidden = false
        } else {
            websiteButton.isHidden = true
        }
    }
    
    // MARK: - Avatar Update
    
    func updateAvatar(_ image: UIImage?) {
        if let image = image {
            // Set new image directly
            avatarImageView.image = image
            avatarImageView.tintColor = nil
            avatarImageView.backgroundColor = .clear
        } else {
            // Set system icon directly
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
            avatarImageView.backgroundColor = .clear
            
            print("DEBUG: updateAvatar setting system icon directly")
        }
    }
}

// MARK: - ReuseIdentifying

extension ProfileHeaderCell: ReuseIdentifying {}
