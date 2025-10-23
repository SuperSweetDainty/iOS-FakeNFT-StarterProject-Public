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
        if isLiked {
            likedNFTs.insert(nftId)
        } else {
            likedNFTs.remove(nftId)
        }
        
        // Save locally immediately
        saveLikedNFTs()
        updateFavoriteNFTs()
        
        // Update UI optimistically
        if favoriteNFTs.isEmpty {
            view?.showEmptyState()
        } else {
            view?.displayNFTs(favoriteNFTs, likedNFTs: likedNFTs)
        }
        
        // Sync with server
        servicesAssembly.profileService.updateLikes(Array(likedNFTs)) { [weak self] result in
            switch result {
            case .success:
                self?.postLikedNFTsNotification()
            case .failure:
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
}

