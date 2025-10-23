//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import Foundation

final class CartPresenter {
    // MARK: - Properties
    private let requestNetwork: NetworkClient
    weak var view: UpdateCartProtocol?
    
    // MARK: - init
    init(view: UpdateCartProtocol, networkService: NetworkClient = DefaultNetworkClient()) {
        self.view = view
        self.requestNetwork = networkService
    }
    
    // MARK: - Life Cycle
    func viewDidLoad() {
        extractionNFT()
    }
    
    // MARK: - Method
    private func extractionNFT() {
        let request = RequestForCart()
        requestNetwork.send(request: request, type: ResponseCart.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                print(response)
                self.view?.nftUpdate(with: response.nfts)
                case .failure(let error):
                print(error)
            }
        }
    }
}
