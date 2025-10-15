import UIKit

// MARK: - MyNFTCell

final class MyNFTCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Properties
    
    private var onLikeTapped: ((Bool) -> Void)?
    private var isLiked: Bool = false
    
    // MARK: - UI Elements
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        button.tintColor = .white // обычный цвет - белый
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hexString: "1A1B22")
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(hexString: "1A1B22")
        label.text = "Цена"
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceValueLabel: UILabel = {
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
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [nftImageView, likeButton, nameLabel, authorLabel, priceLabel, priceValueLabel, ratingStackView].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // NFT Image - слева от ячейки (16 от экрана)
            nftImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nftImageView.widthAnchor.constraint(equalTo: nftImageView.heightAnchor),
            
            // Like button
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Name label - прикован к левому верхнему краю container view, 20 слева от NFT изображения, 23 сверху от границы ячейки
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            // Rating stack view - 0 слева от container view (относительно NFT изображения + 20), 4 сверху от name label
            ratingStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            // Author label - 0 слева от container view (относительно NFT изображения + 20), 4 сверху от rating
            authorLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            // Price label - 39 слева от author, 10 сверху от границы container view (относительно NFT изображения + 20)
            priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 33), // 23 + 10
            priceLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 39),
            
            // Price value label - на 2 вниз от price label, на 1 влево от него
            priceValueLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            priceValueLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -1)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft, isLiked: Bool, onLikeTapped: @escaping (Bool) -> Void) {
        self.isLiked = isLiked
        self.onLikeTapped = onLikeTapped
        
        nameLabel.text = nft.name
        authorLabel.text = "от \(nft.author)"
        priceValueLabel.text = "\(nft.price) ETH"
        
        // Set NFT image based on name
        switch nft.name {
        case "Lilo":
            nftImageView.image = UIImage(resource: .lilo)
        case "Spring":
            nftImageView.image = UIImage(resource: .spring)
        case "April":
            nftImageView.image = UIImage(resource: .april)
        default:
            nftImageView.image = UIImage(resource: .lilo)
        }
        
        // Configure like button
        likeButton.isSelected = isLiked
        
        // Устанавливаем правильный цвет кнопки
        if isLiked {
            likeButton.tintColor = UIColor(hexString: "F56B6C") // красный цвет для активного состояния
        } else {
            likeButton.tintColor = .white // белый цвет для обычного состояния
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
        
        // Меняем цвет кнопки в зависимости от состояния
        if isLiked {
            likeButton.tintColor = UIColor(hexString: "F56B6C") // красный цвет для активного состояния
        } else {
            likeButton.tintColor = .white // белый цвет для обычного состояния
        }
        
        onLikeTapped?(isLiked)
    }
}

// MARK: - MyNFTViewController

final class MyNFTViewController: UIViewController {
    
    // MARK: - Properties
    
    private var nfts: [Nft] = []
    private var likedNFTs: Set<String> = []
    private var currentSortCriteria: SortCriteria = .price
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .background
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        // Register cells
        tableView.register(MyNFTCell.self, forCellReuseIdentifier: "MyNFTCell")
        
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "У Вас ещё нет NFT"
        label.font = .headline3
        label.textColor = UIColor(hexString: "1A1B22")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupConstraints()
        setupNotifications()
        loadNFTs()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [tableView, emptyStateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupNavigationBar() {
        // Back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: "1A1B22")
        
        // Title
        navigationItem.title = "Мои NFT"
        
        // Sort button
        let sortButton = UIBarButtonItem(
            image: UIImage(resource: .vector),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButton.tintColor = UIColor(hexString: "1A1B22")
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadNFTs() {
        // Create test NFT data
        let liloNFT = Nft(
            id: "1",
            name: "Lilo",
            price: 1.78,
            rating: 3,
            images: [URL(string: "https://example.com/lilo.png")!],
            author: "John Doe"
        )
        
        let springNFT = Nft(
            id: "2",
            name: "Spring",
            price: 1.78,
            rating: 3,
            images: [URL(string: "https://example.com/spring.png")!],
            author: "John Doe"
        )
        
        let aprilNFT = Nft(
            id: "3",
            name: "April",
            price: 1.78,
            rating: 3,
            images: [URL(string: "https://example.com/april.png")!],
            author: "John Doe"
        )
        
        nfts = [liloNFT, springNFT, aprilNFT]
        
        // Load liked NFTs from UserDefaults
        loadLikedNFTs()
        
        // Load saved sort criteria and apply it
        loadSavedSortCriteria()
        applyCurrentSort()
        
        updateUI()
    }
    
    private func loadLikedNFTs() {
        if let likedNFTsData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedNFTsSet = try? JSONDecoder().decode(Set<String>.self, from: likedNFTsData) {
            likedNFTs = likedNFTsSet
        }
    }
    
    private func saveLikedNFTs() {
        if let likedNFTsData = try? JSONEncoder().encode(likedNFTs) {
            UserDefaults.standard.set(likedNFTsData, forKey: "LikedNFTs")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(likedNFTsDidChange),
            name: .likedNFTsDidChange,
            object: nil
        )
    }
    
    @objc private func likedNFTsDidChange() {
        loadLikedNFTs()
        tableView.reloadData()
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.nfts.isEmpty {
                self.emptyStateLabel.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.emptyStateLabel.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonTapped() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        // Add actions for each sort criteria
        for criteria in SortCriteria.allCases {
            let action = UIAlertAction(title: criteria.title, style: .default) { [weak self] _ in
                self?.sortNFTs(by: criteria)
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func sortNFTs(by criteria: SortCriteria) {
        currentSortCriteria = criteria
        saveSortCriteria(criteria)
        applyCurrentSort()
    }
    
    private func applyCurrentSort() {
        switch currentSortCriteria {
        case .price:
            nfts.sort { $0.price > $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        case .name:
            nfts.sort { $0.name < $1.name }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UserDefaults
    
    private func saveSortCriteria(_ criteria: SortCriteria) {
        UserDefaults.standard.set(criteria.rawValue, forKey: UserDefaultsKeys.selectedSortCriteria)
    }
    
    private func loadSavedSortCriteria() {
        if let savedCriteriaString = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedSortCriteria),
           let savedCriteria = SortCriteria(rawValue: savedCriteriaString) {
            currentSortCriteria = savedCriteria
        }
    }
    
    private enum SortCriteria: String, CaseIterable {
        case price = "price"
        case rating = "rating"
        case name = "name"
        
        var title: String {
            switch self {
            case .price:
                return "По цене"
            case .rating:
                return "По рейтингу"
            case .name:
                return "По названию"
            }
        }
    }
    
    private enum UserDefaultsKeys {
        static let selectedSortCriteria = "MyNFTSelectedSortCriteria"
    }
}

// MARK: - UITableViewDataSource

extension MyNFTViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return nfts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyNFTCell", for: indexPath) as! MyNFTCell
        let nft = nfts[indexPath.section]
        let isLiked = likedNFTs.contains(nft.id)
        
        cell.configure(with: nft, isLiked: isLiked) { [weak self] (isLiked: Bool) in
            if isLiked {
                self?.likedNFTs.insert(nft.id)
            } else {
                self?.likedNFTs.remove(nft.id)
            }
            
            // Save to UserDefaults
            self?.saveLikedNFTs()
            
            // Post notification
            NotificationCenter.default.post(name: .likedNFTsDidChange, object: nil)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyNFTViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
}
