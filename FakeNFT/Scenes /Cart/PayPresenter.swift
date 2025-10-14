//
//  PayPresenter.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import Foundation

final class PayPresenter:PayPresenterProtocol {
    
    weak var view: PayChoosingProtocol?
    private let networkService: NetworkClient
    
    init(view: PayChoosingProtocol, networkService: NetworkClient = DefaultNetworkClient()) {
        self.view = view
        self.networkService = networkService
    }
    
    func viewDidLoad() {
        fetchCollections()
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
}
