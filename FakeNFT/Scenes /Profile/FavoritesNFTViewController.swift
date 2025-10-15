import UIKit

final class FavoritesNFTViewController: UIViewController {
    
    // MARK: - Properties
    
    private var allNFTs: [Nft] = []
    private var likedNFTs: Set<String> = []
    private var favoriteNFTs: [Nft] = []
    
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
        label.text = "У Вас ещё нет избранных NFT"
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
        loadData()
        setupNotifications()
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
        navigationItem.title = "Избранные NFT"
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
        
        allNFTs = [liloNFT, springNFT, aprilNFT]
        
        // Load liked NFTs from UserDefaults
        loadLikedNFTs()
        
        // Filter favorite NFTs
        updateFavoriteNFTs()
        
        updateUI()
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
            
            if self.favoriteNFTs.isEmpty {
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
    
    @objc private func likedNFTsDidChange() {
        loadLikedNFTs()
        updateFavoriteNFTs()
        updateUI()
    }
}

// MARK: - UITableViewDataSource

extension FavoritesNFTViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return favoriteNFTs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyNFTCell", for: indexPath) as! MyNFTCell
        let nft = favoriteNFTs[indexPath.section]
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

// MARK: - UITableViewDelegate

extension FavoritesNFTViewController: UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
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
