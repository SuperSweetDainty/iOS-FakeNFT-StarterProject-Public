//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import Foundation
import ProgressHUD

final class CartPresenter: PresenterCartProtocol {
    // MARK: - Properties
    private let requestNetwork: NetworkClient
    weak var view: UpdateCartProtocol?
    private let cartService: CartServiceProtocol
    private let nftService: NftService
    
    // MARK: - init
    init(view: UpdateCartProtocol, networkService: NetworkClient = DefaultNetworkClient(), cartService: CartServiceProtocol = CartService.shared, nftService: NftService) {
        self.view = view
        self.requestNetwork = networkService
        self.cartService = cartService
        self.nftService = nftService
    }
    
    // MARK: - Life Cycle
    func viewDidLoad() {
        extractionNFT()
    }
    
    // MARK: - Method
    func reloadCart() {
        extractionNFT()
    }
    
    private func extractionNFT() {
        let cartIds = cartService.getCartItems()
        
        guard !cartIds.isEmpty else {
            view?.nftUpdate(with: [])
            return
        }
        
        ProgressHUD.animate()
        
        var loadedNfts: [Nft] = []
        let group = DispatchGroup()
        
        for nftId in cartIds {
            group.enter()
            
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nft):
                    loadedNfts.append(nft)
                case .failure(let error):
                    print("Failed to load NFT \(nftId): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            ProgressHUD.dismiss()
            self?.view?.nftUpdate(with: loadedNfts)
        }
    }
    
    //        let request = RequestForCart()
    //        requestNetwork.send(request: request, type: ResponseCart.self) { [weak self] result in
    //            guard let self else { return }
    //            switch result {
    //            case .success(let response):
    //                print(response)
    //                self.view?.nftUpdate(with: response.nfts)
    //                case .failure(let error):
    //                print(error)
    //            }
    //        }
    //    }
}
