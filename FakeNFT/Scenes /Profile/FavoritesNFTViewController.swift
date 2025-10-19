import UIKit

final class FavoritesNFTViewController: UIViewController, LoadingView {
    
    // MARK: - Properties
    
    private var allNFTs: [Nft] = []
    private var likedNFTs: Set<String> = []
    private var favoriteNFTs: [Nft] = []
    private var isLoading: Bool = false
    
    // MARK: - Error Types
    
    enum NFTLoadError: Error {
        case networkError
        case dataParsingError
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .networkError:
                return "Ошибка загрузки данных"
            case .dataParsingError:
                return "Ошибка обработки данных"
            case .unknown:
                return "Неизвестная ошибка"
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 7 // Горизонтальный отступ между ячейками
        layout.minimumLineSpacing = 20 // Вертикальный отступ между ячейками
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16) // Отступы коллекции
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        collectionView.showsVerticalScrollIndicator = false
        
        // Register cells
        collectionView.register(FavoritesNFTCollectionViewCell.self)
        
        return collectionView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "У Вас ещё нет избранных NFT"
        label.font = .headline3
        label.textColor = UIColor(hexString: "1A1B22")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupConstraints()
        loadData()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [collectionView, emptyStateLabel, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Initially hide collection view and empty label
        collectionView.isHidden = true
        emptyStateLabel.isHidden = true
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
        navigationItem.title = "Избранные NFT"
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    // MARK: - Data Loading
    
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true
        
        // Показываем индикатор загрузки
        showLoading()
        
        // Имитация асинхронной загрузки данных
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Имитация задержки сети
            Thread.sleep(forTimeInterval: 0.5)
            
            // Для тестирования: можно раскомментировать, чтобы имитировать ошибку
            // let shouldSimulateError = Bool.random()
            let shouldSimulateError = false
            
            if shouldSimulateError {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hideLoading()
                    self.handleLoadError(.networkError)
                }
                return
            }
            
            do {
                let nfts = try self.fetchNFTData()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hideLoading()
                    self.allNFTs = nfts
                    
                    // Load liked NFTs from UserDefaults
                    self.loadLikedNFTs()
                    
                    // Filter favorite NFTs
                    self.updateFavoriteNFTs()
                    
                    self.updateUI()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hideLoading()
                    self.handleLoadError(error as? NFTLoadError ?? .unknown)
                }
            }
        }
    }
    
    private func fetchNFTData() throws -> [Nft] {
        // Load test NFT data (same as in MyNFTViewController)
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
        
        let archieNFT = Nft(
            id: "4",
            name: "Archie",
            price: 1.78,
            rating: 3,
            images: [URL(string: "https://example.com/archie.png")!],
            author: "John Doe"
        )
        
        let pixiNFT = Nft(
            id: "5",
            name: "Pixi",
            price: 1.78,
            rating: 3,
            images: [URL(string: "https://example.com/pixi.png")!],
            author: "John Doe"
        )
        
        let melissaNFT = Nft(
            id: "6",
            name: "Melissa",
            price: 1.78,
            rating: 5,
            images: [URL(string: "https://example.com/melissa.png")!],
            author: "John Doe"
        )
        
        let daisyNFT = Nft(
            id: "7",
            name: "Daisy",
            price: 1.78,
            rating: 1,
            images: [URL(string: "https://example.com/daisy.png")!],
            author: "John Doe"
        )
        
        return [liloNFT, springNFT, aprilNFT, archieNFT, pixiNFT, melissaNFT, daisyNFT]
    }
    
    private func handleLoadError(_ error: NFTLoadError) {
        showErrorAlert(message: error.localizedDescription)
    }
    
    private func loadLikedNFTs() {
        if let likedNFTsData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedNFTsSet = try? JSONDecoder().decode(Set<String>.self, from: likedNFTsData) {
            likedNFTs = likedNFTsSet
        }
    }
    
    private func updateFavoriteNFTs() {
        favoriteNFTs = allNFTs.filter { likedNFTs.contains($0.id) }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Show content after loading
            if self.favoriteNFTs.isEmpty {
                self.emptyStateLabel.isHidden = false
                self.collectionView.isHidden = true
            } else {
                self.emptyStateLabel.isHidden = true
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func likedNFTsDidChange() {
        loadLikedNFTs()
        updateFavoriteNFTs()
        updateUI()
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesNFTViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteNFTs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavoritesNFTCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let nft = favoriteNFTs[indexPath.item]
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
            
            // Update UI
            self?.updateFavoriteNFTs()
            self?.updateUI()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FavoritesNFTViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Ширина экрана
        let screenWidth = collectionView.bounds.width
        
        // Отступы коллекции (16 слева + 16 справа)
        let sectionInsets: CGFloat = 16 * 2
        
        // Отступ между ячейками (7)
        let interItemSpacing: CGFloat = 7
        
        // Доступная ширина для двух ячеек
        let availableWidth = screenWidth - sectionInsets - interItemSpacing
        
        // Ширина одной ячейки
        let itemWidth = availableWidth / 2
        
        // Высота ячейки (80 для изображения, но можно сделать побольше для контейнера)
        let itemHeight: CGFloat = 80
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - UserDefaults

extension FavoritesNFTViewController {
    
    private func saveLikedNFTs() {
        if let likedNFTsData = try? JSONEncoder().encode(likedNFTs) {
            UserDefaults.standard.set(likedNFTsData, forKey: "LikedNFTs")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let likedNFTsDidChange = Notification.Name("likedNFTsDidChange")
}
