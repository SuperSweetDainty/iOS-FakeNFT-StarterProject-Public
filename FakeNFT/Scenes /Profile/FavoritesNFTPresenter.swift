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
        saveLikedNFTs()
        postLikedNFTsNotification()
        updateFavoriteNFTs()
        
        if favoriteNFTs.isEmpty {
            view?.showEmptyState()
        } else {
            view?.displayNFTs(favoriteNFTs, likedNFTs: likedNFTs)
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let nfts = self.createTestNFTs()
            
            DispatchQueue.main.async {
                self.allNFTs = nfts
                self.loadLikedNFTs()
                self.updateFavoriteNFTs()
                
                if self.favoriteNFTs.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .loaded(self.favoriteNFTs)
                }
            }
        }
    }
    
    private func createTestNFTs() -> [Nft] {
        return [
            Nft(id: "1", name: "Lilo", price: 1.78, rating: 3, images: [URL(string: "https://example.com/lilo.png")!], author: "John Doe"),
            Nft(id: "2", name: "Spring", price: 1.78, rating: 3, images: [URL(string: "https://example.com/spring.png")!], author: "John Doe"),
            Nft(id: "3", name: "April", price: 1.78, rating: 3, images: [URL(string: "https://example.com/april.png")!], author: "John Doe"),
            Nft(id: "4", name: "Archie", price: 1.78, rating: 3, images: [URL(string: "https://example.com/archie.png")!], author: "John Doe"),
            Nft(id: "5", name: "Pixi", price: 1.78, rating: 3, images: [URL(string: "https://example.com/pixi.png")!], author: "John Doe"),
            Nft(id: "6", name: "Melissa", price: 1.78, rating: 5, images: [URL(string: "https://example.com/melissa.png")!], author: "John Doe"),
            Nft(id: "7", name: "Daisy", price: 1.78, rating: 1, images: [URL(string: "https://example.com/daisy.png")!], author: "John Doe")
        ]
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
           let likedNFTsSet = try? JSONDecoder().decode(Set<String>.self, from: likedNFTsData) {
            likedNFTs = likedNFTsSet
        }
    }
    
    private func saveLikedNFTs() {
        if let likedNFTsData = try? JSONEncoder().encode(likedNFTs) {
            UserDefaults.standard.set(likedNFTsData, forKey: "LikedNFTs")
        }
    }
    
    private func postLikedNFTsNotification() {
        NotificationCenter.default.post(name: .likedNFTsDidChange, object: nil)
    }
}

