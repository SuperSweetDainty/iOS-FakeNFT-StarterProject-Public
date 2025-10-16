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

class CatalogCollectionViewPresenter: CatalogCollectionViewPresenterProtocol {
    
    //MARK: -Public Properties
    weak var view: CatalogCollectionViewControllerProtocol?
    var collectionsCount: Int {
        return nftCollectionCell.count
    }
    
    // MARK: - Private Properties
    private var collectionDetails: CatalogCollectionNft
    private var nftCollectionCell: [NftCellModel] = []
    
    // MARK: -Init
    init(collectionDetails: CatalogCollectionNft) {
        self.collectionDetails = collectionDetails
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
    
    
    // MARK: - Public Methods
    func collection(at index: Int) -> NftCellModel {
        nftCollectionCell[index]
    }
    
    func didTapLike(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        nftCollectionCell[index].isFavorite.toggle()
        saveLikeState(nftId: nftId, isLiked: nftCollectionCell[index].isFavorite)
        
        // Отправляем уведомление
        NotificationCenter.default.post(
            name: .nftLikeStateChanged,
            object: nil,
            userInfo: ["nftId": nftId, "isLiked": nftCollectionCell[index].isFavorite]
        )
    }
    
    func didTapCart(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        nftCollectionCell[index].isInCart.toggle()
        saveCartState(nftId: nftId, isInCart: nftCollectionCell[index].isInCart)
        
        // Отправляем уведомление
        NotificationCenter.default.post(
            name: .nftCartStateChanged,
            object: nil,
            userInfo: ["nftId": nftId, "isInCart": nftCollectionCell[index].isInCart]
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
    }
    
    private func loadNFTs(){
        view?.showLoading()
        
        // Имитация загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            let shouldFail = false // Для теста ошибка true
            let isEmptyCollection = false // true - пустая коллекция
            
            if shouldFail {
                self.view?.showError("Нет удалось загрузить коллекцию")
            }  else if isEmptyCollection {
                self.nftCollectionCell = []
                self.view?.showEmptyState()
            } else {
                self.nftCollectionCell = self.createMockNftCollections()
                self.view?.displayCollections(self.nftCollectionCell)
            }
            
            self.view?.hideLoading()
        }
    }
    
    private func saveLikeState(nftId: String, isLiked: Bool) {
        // Мок-сохранение в UserDefaults
        UserDefaults.standard.set(isLiked, forKey: "nft_like_\(nftId)")
        print("NFT \(nftId) like state: \(isLiked ? "liked" : "unliked")")
        
    }
    
    private func loadLikeState(nftId: String) -> Bool {
        UserDefaults.standard.bool(forKey: "nft_like_\(nftId)")
    }
    
    private func saveCartState(nftId: String, isInCart: Bool) {
        // Мок-сохранение в UserDefaults
        UserDefaults.standard.set(isInCart, forKey: "nft_cart_\(nftId)")
        print("NFT \(nftId) like state: \(isInCart ? "cart" : "noCart")")
    }
    
    private func loadCartState(nftId: String) -> Bool {
        return UserDefaults.standard.bool(forKey: "nft_cart_\(nftId)")
    }
    
    // MARK: - Mock
    private func createMockNftCollections() -> [NftCellModel] {
        let mockNFTs = [
            NftCellModel(id: "1", name: "Archie", images: "nftCardsOne", rating: 2, price: 1, isFavorite: true, isInCart: false),
            NftCellModel(id: "2", name: "Ruby", images: "nftCardsTwo", rating: 2, price: 2, isFavorite: true, isInCart: true),
            NftCellModel(id: "3", name: "Nacho", images: "nftCardsThree", rating: 3, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "4", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "5", name: "Daisy", images: "nftCardsThree", rating: 1, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "6", name: "Susan", images: "nftCardsTwo", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "7", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
        ]
        
        return mockNFTs.map { nft in
            var updatedNft = nft
            updatedNft.isFavorite = self.loadLikeState(nftId: nft.id)
            updatedNft.isInCart = self.loadCartState(nftId: nft.id)
            return updatedNft
        }
    }
}
