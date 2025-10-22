import UIKit

final class FavoritesNFTViewController: UIViewController {
    
    private let presenter: FavoritesNFTPresenter
    private let servicesAssembly: ServicesAssembly
    private var favoriteNFTs: [Nft] = []
    private var likedNFTs: Set<String> = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .background
        collectionView.showsVerticalScrollIndicator = false
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(servicesAssembly: ServicesAssembly, presenter: FavoritesNFTPresenter) {
        self.servicesAssembly = servicesAssembly
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [collectionView, emptyStateLabel, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        collectionView.isHidden = true
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func likedNFTsDidChange() {
        collectionView.reloadData()
    }
}

extension FavoritesNFTViewController: FavoritesNFTView {
    
    func displayNFTs(_ nfts: [Nft], likedNFTs: Set<String>) {
        self.favoriteNFTs = nfts
        self.likedNFTs = likedNFTs
        
        collectionView.isHidden = false
        emptyStateLabel.isHidden = true
        collectionView.reloadData()
    }
    
    func showEmptyState() {
        collectionView.isHidden = true
        emptyStateLabel.isHidden = false
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showError(message: String, onRetry: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            onRetry()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func openNFTDetail(with id: String) {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let input = NftDetailInput(id: id)
        let nftDetailViewController = assembly.build(with: input)
        present(nftDetailViewController, animated: true)
    }
}

extension FavoritesNFTViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteNFTs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavoritesNFTCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let nft = favoriteNFTs[indexPath.item]
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

extension FavoritesNFTViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let sectionInsets: CGFloat = 16 * 2
        let interItemSpacing: CGFloat = 7
        let availableWidth = screenWidth - sectionInsets - interItemSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = 80
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectNFT(at: indexPath.item)
    }
}

extension FavoritesNFTViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let imageURLs = indexPaths.compactMap { indexPath -> URL? in
            guard indexPath.item < favoriteNFTs.count else { return nil }
            return favoriteNFTs[indexPath.item].images.first
        }
        
        servicesAssembly.imageCacheService.prefetchImages(urls: imageURLs)
    }
}

extension Notification.Name {
    static let likedNFTsDidChange = Notification.Name("likedNFTsDidChange")
}

