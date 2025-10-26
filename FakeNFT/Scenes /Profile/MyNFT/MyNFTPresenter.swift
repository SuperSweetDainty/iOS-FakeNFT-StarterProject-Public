import Foundation

// MARK: - Protocol

protocol MyNFTPresenter {
    func viewDidLoad()
    func didTapSort()
    func didSelectNFT(at index: Int)
    func didToggleLike(for nftId: String, isLiked: Bool)
    func sortNFTs(by criteria: MyNFTSortCriteria)
}

// MARK: - Sort Criteria

enum MyNFTSortCriteria: String, CaseIterable {
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

// MARK: - State

enum MyNFTState {
    case initial
    case loading
    case loaded([Nft])
    case empty
    case failed(Error)
}

// MARK: - View Protocol

protocol MyNFTView: AnyObject {
    func displayNFTs(_ nfts: [Nft], likedNFTs: Set<String>)
    func showEmptyState()
    func showLoading()
    func hideLoading()
    func showSortOptions(_ options: [MyNFTSortCriteria])
    func openNFTDetail(with id: String)
}

// MARK: - Presenter Implementation

final class MyNFTPresenterImpl: MyNFTPresenter {
    
    // MARK: - Properties
    
    weak var view: MyNFTView?
    private let servicesAssembly: ServicesAssembly
    private var nfts: [Nft] = []
    private var likedNFTs: Set<String> = []
    private var currentSortCriteria: MyNFTSortCriteria = .price
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    private var state = MyNFTState.initial {
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
        loadSavedSortCriteria()
        state = .loading
    }
    
    func didTapSort() {
        view?.showSortOptions(MyNFTSortCriteria.allCases)
    }
    
    func sortNFTs(by criteria: MyNFTSortCriteria) {
        currentSortCriteria = criteria
        saveSortCriteria(criteria)
        applySort()
    }
    
    func didSelectNFT(at index: Int) {
        guard index < nfts.count else { return }
        let nft = nfts[index]
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
        
        // Update UI optimistically
        view?.displayNFTs(nfts, likedNFTs: likedNFTs)
        
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
        case .loaded(let nfts):
            view?.hideLoading()
            self.nfts = nfts
            applySort()
        case .empty:
            view?.hideLoading()
            view?.showEmptyState()
        case .failed:
            view?.hideLoading()
        }
    }
    
    private func loadNFTs() {
        // Load profile to get user's NFTs and likes
        servicesAssembly.profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.likedNFTs = Set(user.likes)
                
                // Load user's NFTs details
                if user.nfts.isEmpty {
                    DispatchQueue.main.async {
                        self.state = .empty
                    }
                } else {
                    self.loadUserNFTsDetails(ids: user.nfts)
                }
                
            case .failure:
                // Try to load from local storage
                DispatchQueue.global(qos: .userInitiated).async {
                    self.loadLikedNFTs()
                    
                    DispatchQueue.main.async {
                        self.state = .failed(NetworkClientError.urlSessionError)
                    }
                }
            }
        }
    }
    
    private func loadUserNFTsDetails(ids: [String]) {
        servicesAssembly.nftService.loadNftList(ids: ids) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    if nfts.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .loaded(nfts)
                    }
                    
                case .failure(let error):
                    self.state = .failed(error)
                }
            }
        }
    }
    
    private func applySort() {
        var sortedNFTs = nfts
        
        switch currentSortCriteria {
        case .price:
            sortedNFTs.sort { $0.price > $1.price }
        case .rating:
            sortedNFTs.sort { $0.rating > $1.rating }
        case .name:
            sortedNFTs.sort { 
                let name1 = extractName(from: $0.images.first)
                let name2 = extractName(from: $1.images.first)
                return name1 < name2
            }
        }
        
        nfts = sortedNFTs
        view?.displayNFTs(nfts, likedNFTs: likedNFTs)
    }
    
    // MARK: - UserDefaults
    
    private func loadLikedNFTs() {
        if let likedNFTsData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedNFTsSet = try? jsonDecoder.decode(Set<String>.self, from: likedNFTsData) {
            likedNFTs = likedNFTsSet
        }
    }
    
    private func saveLikedNFTs() {
        if let likedNFTsData = try? jsonEncoder.encode(likedNFTs) {
            UserDefaults.standard.set(likedNFTsData, forKey: "LikedNFTs")
        }
    }
    
    private func saveSortCriteria(_ criteria: MyNFTSortCriteria) {
        UserDefaults.standard.set(criteria.rawValue, forKey: "MyNFTSelectedSortCriteria")
    }
    
    private func loadSavedSortCriteria() {
        if let savedCriteriaString = UserDefaults.standard.string(forKey: "MyNFTSelectedSortCriteria"),
           let savedCriteria = MyNFTSortCriteria(rawValue: savedCriteriaString) {
            currentSortCriteria = savedCriteria
        }
    }
    
    private func postLikedNFTsNotification() {
        NotificationCenter.default.post(name: .likedNFTsDidChange, object: nil)
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
}

