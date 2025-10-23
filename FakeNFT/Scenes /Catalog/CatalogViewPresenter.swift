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
    private var isLoading = false
    private var networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
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
    
    func didTapRetry() {
        loadCollections()
    }
    
    //MARK: - Private Methods
    private func loadCollections() {
        guard !isLoading else { return }
        isLoading = true
        
        view?.showLoading()
        
        networkService.fetchCollections { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let networkCollections):
                let collections = networkCollections.map { networkModel in
                    CatalogCollectionNft(
                        id: networkModel.id,
                        name: networkModel.name,
                        nftCount: networkModel.nfts.count,
                        imageURL: networkModel.cover,
                        nftIds: networkModel.nfts,
                        description: networkModel.description,
                        author: networkModel.author
                    )
                }
                
                self.collectionsNft = collections
                self.applySorting()
                self.view?.hideLoading()
                
                if collections.isEmpty {
                    self.view?.showEmptyState()
                } else {
                    self.view?.displayCollections(collections)
                }
                
            case .failure(let error):
                self.view?.hideLoading()
                self.view?.showError("Ошибка загрузки коллекций")
                print("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
        //loadCollectionSimulation()
        
        // TODO: TEST  Ошибка загрузки
        //            self.collectionsNft = []
        //            self.applySorting()
        //            self.view?.hideLoading()
        //            self.view?.showEmptyState()
    }
    
    // Имитация загрузки
    //private func loadCollectionSimulation() {
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //
    //            let shouldFail = false // Для теста ошибка true
    //
    //            if shouldFail {
    //                self.view?.showError("Нет подключения к интернету")
    //            } else {
    //                self.collectionsNft = self.createMockCollections()
    //                self.applySorting()
    //                self.view?.hideLoading()
    //                self.view?.displayCollections(self.collectionsNft)
    //            }
    //}
    
    //MARK: - Private Methods
    private func applySorting() {
        collectionsNft = currentSortOption.sortCollections(collectionsNft)
        view?.displayCollections(collectionsNft)
    }
}

// MARK: - Mock
//    private func createMockCollections() -> [CatalogCollectionNft] {
//        return [
//            CatalogCollectionNft(id: "1", name: "Коллекция 1", nftCount: 5, imageURL: "collectionOne"),
//            CatalogCollectionNft(id: "2", name: "Коллекция 2", nftCount: 3,  imageURL: "collectionOne"),
//            CatalogCollectionNft(id: "3", name: "Коллекция 3", nftCount: 7,  imageURL: "collectionOne"),
//            CatalogCollectionNft(id: "4", name: "Коллекция 4", nftCount: 2,  imageURL:  "collectionOne"),
//            CatalogCollectionNft(id: "5", name: "Коллекция 5", nftCount: 8,  imageURL: "collectionOne")
//        ]
//    }
