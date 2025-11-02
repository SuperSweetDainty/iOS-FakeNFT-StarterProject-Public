import Foundation

// MARK: - Protocol

protocol FavoritesNFTPresenter {
    func viewDidLoad()
    func didSelectNFT(at index: Int)
    func didToggleLike(for nftId: String, isLiked: Bool)
}

// MARK: - State

enum FavoritesNFTState {
    case initial
    case loading
    case loaded([Nft])
    case empty
    case failed(FavoritesNFTError)
}

// MARK: - Error Types

enum FavoritesNFTError: Error {
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

// MARK: - View Protocol

protocol FavoritesNFTView: AnyObject {
    func displayNFTs(_ nfts: [Nft], likedNFTs: Set<String>)
    func showEmptyState()
    func showLoading()
    func hideLoading()
    func showError(message: String, onRetry: @escaping () -> Void)
    func openNFTDetail(with id: String)
}

// MARK: - Presenter Implementation

final class FavoritesNFTPresenterImpl: FavoritesNFTPresenter {
    
    // MARK: - Properties
    
    weak var view: FavoritesNFTView?
    private let servicesAssembly: ServicesAssembly
    private var allNFTs: [Nft] = []
    private var favoriteNFTs: [Nft] = []
    private var likedNFTs: Set<String> = []
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    private var state = FavoritesNFTState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        
        // Observe unified like-state changes from other screens
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExternalLikeChange(_:)),
            name: .nftLikeStateChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Functions
    
    func viewDidLoad() {
        state = .loading
    }
    
    func didSelectNFT(at index: Int) {
        guard index < favoriteNFTs.count else { return }
        let nft = favoriteNFTs[index]
        view?.openNFTDetail(with: nft.id)
    }
    
    func didToggleLike(for nftId: String, isLiked: Bool) {
        print("📱 Favorites: Toggling like for NFT \(nftId), new state: \(isLiked)")
        print("   Current likes before: \(likedNFTs)")
        
        if isLiked {
            likedNFTs.insert(nftId)
        } else {
            likedNFTs.remove(nftId)
        }
        
        print("   Current likes after: \(likedNFTs)")
        
        // Save locally immediately
        saveLikedNFTs()
        updateFavoriteNFTs()
        
        // Update UI optimistically
        if favoriteNFTs.isEmpty {
            view?.showEmptyState()
        } else {
            view?.displayNFTs(favoriteNFTs, likedNFTs: likedNFTs)
        }
        
        // Broadcast unified like-state change for sync across screens
        NotificationCenter.default.post(
            name: .nftLikeStateChanged,
            object: nil,
            userInfo: [
                "nftId": nftId,
                "isLiked": isLiked
            ]
        )
        
        // Sync with server
        print("📤 Favorites: Sending to server likes: \(Array(likedNFTs))")
        servicesAssembly.profileService.updateLikes(Array(likedNFTs)) { [weak self] result in
            switch result {
            case .success:
                print("✅ Favorites: Server update successful")
                self?.postLikedNFTsNotification()
            case .failure(let error):
                print("❌ Favorites: Server update failed: \(error)")
                // If server update fails, we keep local changes
                // Could implement retry logic or show error to user
                break
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            break
        case .loading:
            view?.showLoading()
            loadNFTs()
        case .loaded:
            view?.hideLoading()
            displayCurrentState()
        case .empty:
            view?.hideLoading()
            view?.showEmptyState()
        case .failed(let error):
            view?.hideLoading()
            view?.showError(message: error.localizedDescription) { [weak self] in
                self?.state = .loading
            }
        }
    }
    
    private func loadNFTs() {
        // Load profile to get liked NFTs
        servicesAssembly.profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.likedNFTs = Set(user.likes)
                
                // Load liked NFTs details
                if user.likes.isEmpty {
                    DispatchQueue.main.async {
                        self.state = .empty
                    }
                } else {
                    self.loadLikedNFTsDetails(ids: user.likes)
                }
                
            case .failure:
                // Try to load from local storage
                DispatchQueue.global(qos: .userInitiated).async {
                    let localLikes = self.loadLikedNFTsSync()
                    
                    DispatchQueue.main.async {
                        self.likedNFTs = localLikes
                        
                        if localLikes.isEmpty {
                            self.state = .empty
                        } else {
                            self.loadLikedNFTsDetails(ids: Array(localLikes))
                        }
                    }
                }
            }
        }
    }
    
    private func loadLikedNFTsDetails(ids: [String]) {
        servicesAssembly.nftService.loadNftList(ids: ids) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    // Сохраняем все загруженные NFT
                    self.allNFTs = nfts
                    
                    // Фильтруем только избранные NFT
                    self.updateFavoriteNFTs()
                    
                    if self.favoriteNFTs.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .loaded(self.favoriteNFTs)
                    }
                    
                case .failure:
                    self.state = .failed(.networkError)
                }
            }
        }
    }
    
    private func updateFavoriteNFTs() {
        favoriteNFTs = allNFTs.filter { likedNFTs.contains($0.id) }
    }
    
    private func displayCurrentState() {
        if favoriteNFTs.isEmpty {
            view?.showEmptyState()
        } else {
            view?.displayNFTs(favoriteNFTs, likedNFTs: likedNFTs)
        }
    }
    
    // MARK: - UserDefaults
    
    private func loadLikedNFTs() {
        if let likedNFTsData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedNFTsSet = try? jsonDecoder.decode(Set<String>.self, from: likedNFTsData) {
            likedNFTs = likedNFTsSet
        }
    }
    
    private func loadLikedNFTsSync() -> Set<String> {
        if let likedNFTsData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedNFTsSet = try? jsonDecoder.decode(Set<String>.self, from: likedNFTsData) {
            return likedNFTsSet
        }
        return []
    }
    
    private func saveLikedNFTs() {
        if let likedNFTsData = try? jsonEncoder.encode(likedNFTs) {
            UserDefaults.standard.set(likedNFTsData, forKey: "LikedNFTs")
        }
    }
    
    private func postLikedNFTsNotification() {
        NotificationCenter.default.post(name: .likedNFTsDidChange, object: nil)
    }
    
    @objc private func handleExternalLikeChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let nftId = userInfo["nftId"] as? String,
            let isLiked = userInfo["isLiked"] as? Bool
        else { return }
        
        // Update local liked set
        if isLiked {
            likedNFTs.insert(nftId)
        } else {
            likedNFTs.remove(nftId)
        }
        saveLikedNFTs()
        
        // If liked added and not present in cache, fetch its details and append
        if isLiked {
            let alreadyLoaded = allNFTs.contains(where: { $0.id == nftId })
            if !alreadyLoaded {
                servicesAssembly.nftService.loadNftList(ids: [nftId]) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let nfts):
                            // Merge newly loaded NFT(s) - avoid duplicates
                            for nft in nfts {
                                if !self.allNFTs.contains(where: { $0.id == nft.id }) {
                                    self.allNFTs.append(nft)
                                }
                            }
                            self.updateFavoriteNFTs()
                            self.displayCurrentState()
                        case .failure:
                            // If fail, still update list (item will appear after next load)
                            self.updateFavoriteNFTs()
                            self.displayCurrentState()
                        }
                    }
                }
                return
            }
        }
        
        // For removal or when already cached, just refilter and update
        updateFavoriteNFTs()
        displayCurrentState()
    }
}

