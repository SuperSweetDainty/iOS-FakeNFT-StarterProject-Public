import UIKit

// MARK: - MyNFTCell

final class MyNFTCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Properties
    
    private var onLikeTapped: ((Bool) -> Void)?
    private var isLiked: Bool = false
    private var imageCacheService: ImageCacheService?
    
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
        button.tintColor = .white
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel any ongoing image load
        if let cacheService = imageCacheService {
            nftImageView.cancelImageLoad(cacheService: cacheService)
        }
        
        // Reset image
        nftImageView.image = nil
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
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nftImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            
            ratingStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            authorLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.trailingAnchor, constant: -39),
            
            priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 33),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -81),
            
            priceValueLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            priceValueLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor)
        ])
    }
    
    func configure(with nft: Nft, isLiked: Bool, imageCacheService: ImageCacheService, onLikeTapped: @escaping (Bool) -> Void) {
        self.isLiked = isLiked
        self.onLikeTapped = onLikeTapped
        self.imageCacheService = imageCacheService
        
        // name = автор, название NFT извлекается из URL изображения
        nameLabel.text = extractName(from: nft.images.first)  // Название NFT из URL
        authorLabel.text = "от \(nft.name)"  // Имя автора
        
        priceValueLabel.text = "\(nft.price) ETH"
        
        // Load image from network with caching
        if let imageURL = nft.images.first {
            let nftName = extractName(from: imageURL)
            let placeholder = placeholderImage(for: nftName)  // Используем извлеченное название для placeholder
            nftImageView.loadImage(from: imageURL, placeholder: placeholder, cacheService: imageCacheService)
        } else {
            nftImageView.image = placeholderImage(for: "NFT")  // Fallback placeholder
        }
        
        likeButton.isSelected = isLiked
        likeButton.tintColor = isLiked ? UIColor(hexString: "F56B6C") : .white
        
        setupRatingStars(rating: nft.rating)
    }
    
    private func placeholderImage(for nftName: String) -> UIImage {
        switch nftName {
        case "Lilo": return UIImage(resource: .lilo)
        case "Spring": return UIImage(resource: .spring)
        case "April": return UIImage(resource: .april)
        case "Pixi": return UIImage(resource: .pixi)
        case "Melissa": return UIImage(resource: .melissa)
        case "Daisy": return UIImage(resource: .daisy)
        case "Archie": return UIImage(resource: .archie)
        case "Piper": return UIImage(resource: .lilo)  // Fallback для Piper
        case "Mowgli": return UIImage(resource: .spring)  // Fallback для Mowgli
        default: return UIImage(resource: .nftLoading)
        }
    }
    
    private func setupRatingStars(rating: Int) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
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
    
    private func extractName(from imageURL: URL?) -> String {
        guard let url = imageURL else { return "NFT" }
        
        let urlString = url.absoluteString
        let components = urlString.components(separatedBy: "/")
        
        // Ищем название NFT в URL
        // Пример: https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Piper/1.png
        // Нужно извлечь "Piper"
        
        for (index, component) in components.enumerated() {
            if component == "NFT" && index + 2 < components.count {
                // После "NFT" идут цвет и название
                let nameComponent = components[index + 2]
                return nameComponent.capitalized
            }
        }
        
        // Fallback - ищем последний значимый компонент
        for component in components.reversed() {
            if !component.isEmpty && component != "1.png" && component != "2.png" && component != "3.png" {
                return component.capitalized
            }
        }
        
        return "NFT"
    }
    
    private func extractAuthorName(from urlString: String) -> String {
        // Пытаемся извлечь имя из URL
        if let url = URL(string: urlString) {
            let host = url.host ?? ""
            // Убираем домен и оставляем только имя
            let components = host.components(separatedBy: ".")
            if let firstComponent = components.first, !firstComponent.isEmpty {
                // Заменяем подчеркивания на пробелы и форматируем
                let formattedName = firstComponent
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
                return formattedName
            }
        }
        
        // Fallback - возвращаем часть URL
        let components = urlString.components(separatedBy: "/")
        if let lastComponent = components.last, !lastComponent.isEmpty {
            let formattedName = lastComponent
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
            return formattedName
        }
        
        return "Автор"
    }
    
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        likeButton.isSelected = isLiked
        likeButton.tintColor = isLiked ? UIColor(hexString: "F56B6C") : .white
        onLikeTapped?(isLiked)
    }
}

// MARK: - MyNFTViewController

final class MyNFTViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter: MyNFTPresenter
    private let servicesAssembly: ServicesAssembly
    private var nfts: [Nft] = []
    private var likedNFTs: Set<String> = []
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.backgroundColor = .background
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly, presenter: MyNFTPresenter) {
        self.servicesAssembly = servicesAssembly
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupConstraints()
        setupNotifications()
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [tableView, emptyStateLabel, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        tableView.isHidden = true
        emptyStateLabel.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: "1A1B22")
        
        navigationItem.title = "Мои NFT"
        
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
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(likedNFTsDidChange),
            name: .likedNFTsDidChange,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonTapped() {
        presenter.didTapSort()
    }
    
    @objc private func likedNFTsDidChange() {
        tableView.reloadData()
    }
}

// MARK: - MyNFTView

extension MyNFTViewController: MyNFTView {
    
    func displayNFTs(_ nfts: [Nft], likedNFTs: Set<String>) {
        self.nfts = nfts
        self.likedNFTs = likedNFTs
        
        tableView.isHidden = false
        emptyStateLabel.isHidden = true
        tableView.reloadData()
    }
    
    func showEmptyState() {
        tableView.isHidden = true
        emptyStateLabel.isHidden = false
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showSortOptions(_ options: [MyNFTSortCriteria]) {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        for criteria in options {
            let action = UIAlertAction(title: criteria.title, style: .default) { [weak self] _ in
                self?.presenter.sortNFTs(by: criteria)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    func openNFTDetail(with id: String) {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let input = NftDetailInput(id: id)
        let nftDetailViewController = assembly.build(with: input)
        present(nftDetailViewController, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyNFTCell", for: indexPath) as? MyNFTCell else {
            return UITableViewCell()
        }
        let nft = nfts[indexPath.section]
        let isLiked = likedNFTs.contains(nft.id)
        
        cell.configure(
            with: nft,
            isLiked: isLiked,
            imageCacheService: servicesAssembly.imageCacheService
        ) { [weak self] (isLiked: Bool) in
            self?.presenter.didToggleLike(for: nft.id, isLiked: isLiked)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectNFT(at: indexPath.section)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension MyNFTViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let imageURLs = indexPaths.compactMap { indexPath -> URL? in
            guard indexPath.section < nfts.count else { return nil }
            return nfts[indexPath.section].images.first
        }
        
        servicesAssembly.imageCacheService.prefetchImages(urls: imageURLs)
    }
}

