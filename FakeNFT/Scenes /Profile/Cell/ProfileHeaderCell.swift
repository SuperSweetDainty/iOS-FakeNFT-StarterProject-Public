import UIKit
import Kingfisher

final class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = .yaBlackLight
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyRegular
        label.textColor = .yaBlackLight
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
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .editButton), for: .normal)
        button.tintColor = .yaBlackLight
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var onEditTap: (() -> Void)?
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
        
        [avatarImageView, nameLabel, descriptionLabel, websiteButton, editButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // MARK: - Edit Button
                    editButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
                    editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),
                    editButton.widthAnchor.constraint(equalToConstant: 42),
                    editButton.heightAnchor.constraint(equalToConstant: 42),
                    
                    // MARK: - Avatar (иконка)
                    avatarImageView.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 20),
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
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func editButtonTapped() {
        onEditTap?()
    }
    
    @objc private func websiteButtonTapped() {
        onWebsiteTap?()
    }
    
    // MARK: - Configuration
    
    func configure(with user: User, onEditTap: @escaping () -> Void, onWebsiteTap: @escaping () -> Void) {
        self.onEditTap = onEditTap
        self.onWebsiteTap = onWebsiteTap
        
        nameLabel.text = user.name
        descriptionLabel.text = user.description
        
        if let avatarURL = user.avatar {
            avatarImageView.kf.setImage(with: avatarURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }
        
        if let website = user.website {
            websiteButton.setTitle(website.absoluteString, for: .normal)
            websiteButton.isHidden = false
        } else {
            websiteButton.isHidden = true
        }
    }
}

// MARK: - ReuseIdentifying

extension ProfileHeaderCell: ReuseIdentifying {}
