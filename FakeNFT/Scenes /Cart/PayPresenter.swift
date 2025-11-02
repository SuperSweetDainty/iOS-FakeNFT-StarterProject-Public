//
//  PayPresenter.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import Foundation

final class PayPresenter: PayPresenterProtocol {
    
    weak var view: PayChoosingProtocol?
    private let cartService = CartService()
    private let networkService: NetworkClient
    private var nfts: [Nft]
    private var onSuccess: () -> Void
    
    init(view: PayChoosingProtocol,
         nfts: [Nft] = [],
         onSuccess: @escaping () -> Void,
         networkService: NetworkClient = DefaultNetworkClient()) {
        self.view = view
        self.nfts = nfts
        self.onSuccess = onSuccess
        self.networkService = networkService
    }
    
    func viewDidLoad() {
        fetchCollections()
    }
    
    func pay() {
        let ids = nfts.map({$0.id})
        payNext(ids: ids)
    }
    
    private func fetchCollections() {
        view?.showLoading()
        let request = PayRequest()
        networkService.send(request: request, type: [Coin].self) { [weak self] result in
            guard let self else { return }
            self.view?.hideLoading()
            switch result {
                case .success(let response):
                    print(response)
                    self.view?.payUpdate(with: response)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    private func payNext(ids: [String]) {
        guard let id = ids.first else {
            onSuccess()
            view?.presentSuccessScreen()
            return
        }
        view?.showLoading()
        let dto = NftsOrder(nfts: id)
        let request = NftsRequestOrder(dto: dto)
        
        networkService.send(request: request, type: ResponseOrder.self) { [weak self] result in
            guard let self else { return }
            self.view?.hideLoading()
            
            switch result {
                case .success(let result):
                    print(result)
                    self.payNext(ids: Array(ids.dropFirst()))
                    cartService.clearCart()
                case .failure(let error):
                    print(error)
                    self.view?.showRetryAlert { [weak self] in
                        self?.pay()
                    }
            }
        }
    }
}
