//
//  CatalogCollectionViewPresenter.swift
//  FakeNFT
//
//  Created by Irina Gubina on 16.10.2025.
//

import Foundation

protocol CatalogCollectionViewPresenterProtocol {
    var view: CatalogCollectionViewControllerProtocol? { get set }
    var collectionsCount: Int { get }
    func viewDidLoad()
    func collection(at index: Int) -> NftCellModel
    func didTapLike(for nftId: String)
    func didTapCart(for nftId: String)
    func didTapRetry()
}

final class CatalogCollectionViewPresenter: CatalogCollectionViewPresenterProtocol {
    
    //MARK: -Public Properties
    weak var view: CatalogCollectionViewControllerProtocol?
    var collectionsCount: Int {
        return nftCollectionCell.count
    }
    
    // MARK: - Private Properties
    private var collectionDetails: CatalogCollectionNft
    private var nftCollectionCell: [NftCellModel] = []
    private let networkService: NetworkServiceProtocol
    private let cartService: CartServiceProtocol
    private let profileService: ProfileService
    private let nftService: NftService
    private var isLoading = false
    
    // MARK: -Init
    init(collectionDetails: CatalogCollectionNft,
         networkService: NetworkServiceProtocol = NetworkService(),
         cartService: CartServiceProtocol = CartService.shared,
         profileService: ProfileService,
         nftService: NftService) {
        self.collectionDetails = collectionDetails
        self.networkService = networkService
        self.cartService = cartService
        self.profileService = profileService
        self.nftService = nftService
        setupObservers()
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        loadNFTs()
    }
    
    //MARK: - IB Actions
    @objc private func handleLikeUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let nftId = userInfo["nftId"] as? String,
              let isLiked = userInfo["isLiked"] as? Bool,
              let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        // Обновляем данные
        nftCollectionCell[index].isFavorite = isLiked
        
        DispatchQueue.main.async {
            self.view?.displayCollections(self.nftCollectionCell)
        }
    }
    
    @objc private func handleCartUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let nftId = userInfo["nftId"] as? String,
              let isInCart = userInfo["isInCart"] as? Bool,
              let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        // Обновляем данные
        nftCollectionCell[index].isInCart = isInCart
        
        DispatchQueue.main.async {
            self.view?.displayCollections(self.nftCollectionCell)
        }
    }
    
    @objc private func handleCartClear(_ notification: Notification) {
        for index in nftCollectionCell.indices {
            nftCollectionCell[index].isInCart = false
        }
        
        DispatchQueue.main.async {
            self.view?.displayCollections(self.nftCollectionCell)
        }
        
        print("Cart cleared - all NFT cart icons updated to off")
    }
    
    
    // MARK: - Public Methods
    func collection(at index: Int) -> NftCellModel {
        nftCollectionCell[index]
    }
    
    func didTapLike(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        let newLikeState = !nftCollectionCell[index].isFavorite
        
        nftCollectionCell[index].isFavorite = newLikeState
        view?.updateNFTLikeState(at: index, isLiked: newLikeState)
        
        profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    var updatedLikes = Set(user.likes)
                    
                    if newLikeState {
                        updatedLikes.insert(nftId)
                    } else {
                        updatedLikes.remove(nftId)
                    }
                    
                    self?.saveLikesToUserDefaults(Array(updatedLikes))
                    
                    self?.profileService.updateLikes(Array(updatedLikes)) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let updatedUser):
                                
                                NotificationCenter.default.post(
                                    name: .nftLikeStateChanged,
                                    object: nil,
                                    userInfo: ["nftId": nftId, "isLiked": newLikeState]
                                )
                                
                            case .failure(let error):
                                print(" Failed to update likes: \(error)")
                                self?.nftCollectionCell[index].isFavorite = !newLikeState
                                self?.view?.updateNFTLikeState(at: index, isLiked: !newLikeState)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to load profile: \(error)")
                    self?.nftCollectionCell[index].isFavorite = !newLikeState
                    self?.view?.updateNFTLikeState(at: index, isLiked: !newLikeState)
                }
            }
        }
    }
    
    func didTapCart(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        let newCartState = !nftCollectionCell[index].isInCart
        
        if newCartState {
            cartService.addToCart(nftId: nftId)
        } else {
            cartService.removeFromCart(nftId: nftId)
        }
        
        nftCollectionCell[index].isInCart = newCartState
        
        view?.updateNFTCartState(at: index, isInCart: newCartState)
        
        print("Cart tapped for NFT: \(nftId), new state: \(newCartState ? "in cart" : "not in cart")")
        
        // Отправляем уведомление
        NotificationCenter.default.post(
            name: .nftCartStateChanged,
            object: nil,
            userInfo: ["nftId": nftId, "isInCart": newCartState]
        )
    }
    
    func didTapRetry() {
        loadNFTs()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLikeUpdate(_:)),
            name: .nftLikeStateChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCartUpdate(_:)),
            name: .nftCartStateChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCartClear(_:)),
            name: .nftCartCleared,
            object: nil
        )
    }
    
    private func saveLikesToUserDefaults(_ likes: [String]) {
        if let likedData = try? JSONEncoder().encode(Set(likes)) {
            UserDefaults.standard.set(likedData, forKey: "LikedNFTs")
        }
    }
    
    private func loadNFTs(){
        guard !isLoading else { return }
        isLoading = true
        
        view?.showLoading()
        
        let nftIds = collectionDetails.nftIds
        var seenIds = Set<String>()
        let uniqueIds = nftIds.filter { id in
            if seenIds.contains(id) { return false }
            seenIds.insert(id)
            return true
        }
        
        // ИСПОЛЬЗУЕМ ТОТ ЖЕ СЕРВИС, ЧТО И В ПРОФИЛЕ
        nftService.loadNftList(ids: uniqueIds) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            self.view?.hideLoading()
            
            switch result {
            case .success(let nfts):
                
                let nftCellModels = nfts.map { nft in
                    NftCellModel(
                        id: nft.id,
                        name: nft.name,
                        images: nft.images.first?.absoluteString ?? "",
                        rating: nft.rating,
                        price: nft.price,
                        isFavorite: self.loadLikeState(nftId: nft.id),
                        isInCart: self.loadCartState(nftId: nft.id)
                    )
                }
                
                let sortedModels = nftCellModels.sorted { first, second in
                    let firstIndex = uniqueIds.firstIndex(of: first.id) ?? 0
                    let secondIndex = uniqueIds.firstIndex(of: second.id) ?? 0
                    return firstIndex < secondIndex
                }
                
                self.nftCollectionCell = sortedModels
                
                if sortedModels.isEmpty {
                    self.view?.showEmptyState()
                } else {
                    self.view?.displayCollections(sortedModels)
                }
                
            case .failure(let error):
                print("Catalog: Failed to load NFTs: \(error)")
                self.view?.showError("Ошибка загрузки NFT: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadLikeState(nftId: String) -> Bool {
        if let likedData = UserDefaults.standard.data(forKey: "LikedNFTs"),
           let likedSet = try? JSONDecoder().decode(Set<String>.self, from: likedData) {
            return likedSet.contains(nftId)
        }
        return false
    }
    
    private func loadCartState(nftId: String) -> Bool {
        return cartService.isInCart(nftId: nftId)
    }
}

//    // MARK: - Mock
//    private func createMockNftCollections() -> [NftCellModel] {
//        let mockNFTs = [
//            NftCellModel(id: "1", name: "Archie", images: "nftCardsOne", rating: 2, price: 1, isFavorite: true, isInCart: false),
//            NftCellModel(id: "2", name: "Ruby", images: "nftCardsTwo", rating: 2, price: 2, isFavorite: true, isInCart: true),
//            NftCellModel(id: "3", name: "Nacho", images: "nftCardsThree", rating: 3, price: 1, isFavorite: false, isInCart: true),
//            NftCellModel(id: "4", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
//            NftCellModel(id: "5", name: "Daisy", images: "nftCardsThree", rating: 1, price: 1, isFavorite: false, isInCart: true),
//            NftCellModel(id: "6", name: "Susan", images: "nftCardsTwo", rating: 2, price: 1, isFavorite: false, isInCart: true),
//            NftCellModel(id: "7", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
//        ]
//
//        return mockNFTs.map { nft in
//            var updatedNft = nft
//            updatedNft.isFavorite = self.loadLikeState(nftId: nft.id)
//            updatedNft.isInCart = self.loadCartState(nftId: nft.id)
//            return updatedNft
//        }
//    }
