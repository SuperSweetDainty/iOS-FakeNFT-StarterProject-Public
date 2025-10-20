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
        saveLikedNFTs()
        postLikedNFTsNotification()
        view?.displayNFTs(nfts, likedNFTs: likedNFTs)
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let nfts = self.createTestNFTs()
            
            DispatchQueue.main.async {
                self.loadLikedNFTs()
                self.state = nfts.isEmpty ? .empty : .loaded(nfts)
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
    
    private func applySort() {
        var sortedNFTs = nfts
        
        switch currentSortCriteria {
        case .price:
            sortedNFTs.sort { $0.price > $1.price }
        case .rating:
            sortedNFTs.sort { $0.rating > $1.rating }
        case .name:
            sortedNFTs.sort { $0.name < $1.name }
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
}

