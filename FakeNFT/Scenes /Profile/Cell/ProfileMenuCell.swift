import UIKit

final class ProfileMenuCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(hexString: "1A1B22")
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        imageView.tintColor = UIColor(hexString: "1A1B22")
        imageView.contentMode = .center
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .background
        accessoryType = .none
        
        [titleLabel, chevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

extension ProfileMenuCell: ReuseIdentifying {}
