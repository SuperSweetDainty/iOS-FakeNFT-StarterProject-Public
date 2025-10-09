//
//  CatalogViewPresenter.swift
//  FakeNFT
//
//  Created by Irina Gubina on 09.10.2025.
//

import Foundation

protocol CatalogViewPresenterProtocol: AnyObject {
    var view: CatalogViewControllerProtocol? { get set }
    func viewDidLoad()
    func didSelectSortOption(_ option: SortOption)
    func didSelectCollection(at index: Int)
    func didTapRetry()
    
    var collectionsCount: Int { get }
    func collection(at index: Int) -> CatalogCollectionNft
}

final class CatalogViewPresenter: CatalogViewPresenterProtocol {
    //MARK: - Public Properties
    weak var view: CatalogViewControllerProtocol?
    var collectionsCount: Int {
        return collectionsNft.count
    }
    
    //MARK: - Private Properties
    private var collectionsNft: [CatalogCollectionNft] = []
    private var currentSortOption: SortOption = .byName
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        currentSortOption = SortOption.load()
        loadCollections()
    }
    
    //MARK: - Public Methods
    func collection(at index: Int) -> CatalogCollectionNft {
        return collectionsNft[index]
    }
    
    func didSelectSortOption(_ option: SortOption) {
        currentSortOption = option
        currentSortOption.save()
        applySorting()
    }
    
    func didSelectCollection(at index: Int) {
        guard collectionsNft.indices.contains(index) else { return }
        let collection = collectionsNft[index]
        view?.navigateToCollectionDetail(collectionId: collection.id)
    }
    
    func didTapRetry() {
        loadCollections()
    }
    
    //MARK: - Private Methods
    private func loadCollections() {
        view?.showLoading()
        // Имитация загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            let shouldFail = false // Для теста ошибка true
            
            if shouldFail {
                self.view?.showError("Нет подключения к интернету")
            } else {
                self.collectionsNft = self.createMockCollections()
                self.applySorting()
                self.view?.hideLoading()
                self.view?.displayCollections(self.collectionsNft)
            }
            
            // TODO: TEST  Ошибка загрузки
            //            self.collectionsNft = []
            //            self.applySorting()
            //            self.view?.hideLoading()
            //            self.view?.showEmptyState()
        }
    }
    
    //MARK: - Private Methods
    private func applySorting() {
        collectionsNft = currentSortOption.sortCollections(collectionsNft)
        view?.displayCollections(collectionsNft)
    }
    
    // MARK: - Mock
    private func createMockCollections() -> [CatalogCollectionNft] {
        return [
            CatalogCollectionNft(id: "1", name: "Коллекция 1", nftCount: 5, imageURL: "collectionOne"),
            CatalogCollectionNft(id: "2", name: "Коллекция 2", nftCount: 3,  imageURL: "collectionTwo"),
            CatalogCollectionNft(id: "3", name: "Коллекция 3", nftCount: 7,  imageURL: "collectionThree"),
            CatalogCollectionNft(id: "4", name: "Коллекция 4", nftCount: 2,  imageURL:  "collectionOne"),
            CatalogCollectionNft(id: "5", name: "Коллекция 5", nftCount: 8,  imageURL: "collectionThree")
        ]
    }
}
