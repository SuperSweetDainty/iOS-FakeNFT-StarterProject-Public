//
//  NetworkService.swift
//  FakeNFT
//
//  Created by Irina Gubina on 20.10.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchCollections(completion: @escaping (Result<[CollectionNetworkModel], Error>) -> Void)
    func fetchCollectionDetail(by id: String, completion: @escaping (Result<CollectionNetworkModel, Error>) -> Void)
    func fetchNFTs(by ids: [String], completion: @escaping (Result<[NFTNetworkModel], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    // GET запрос для получения списка коллекций
    func fetchCollections(completion: @escaping (Result<[CollectionNetworkModel], Error>) -> Void) {
        let request = CollectionsRequest()
        
        networkClient.send(request: request, type: [CollectionNetworkModel].self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // GET запрос для получения деталей коллекции по ID
    func fetchCollectionDetail(by id: String, completion: @escaping (Result<CollectionNetworkModel, Error>) -> Void) {
        let request = CollectionDetailRequest(collectionId: id)
        
        networkClient.send(request: request, type: CollectionNetworkModel.self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // GET запрос для получения данных NFT по IDs
    func fetchNFTs(by ids: [String], completion: @escaping (Result<[NFTNetworkModel], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var nfts: [NFTNetworkModel] = []
        var errors: [Error] = []
        
        for id in ids {
            dispatchGroup.enter()
            
            let request = NFTRequest(id: id)
            
            networkClient.send(request: request, type: NFTNetworkModel.self) { result in
                switch result {
                case .success(let nft):
                    nfts.append(nft)
                case .failure(let error):
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let firstError = errors.first, nfts.isEmpty {
                completion(.failure(firstError))
            } else {
                completion(.success(nfts))
            }
        }
    }
}
