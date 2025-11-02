import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void
typealias NftListCompletion = (Result<[Nft], Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func loadNftList(ids: [String]?, completion: @escaping NftListCompletion)
}

final class NftServiceImpl: NftService {

    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }

        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNftList(ids: [String]?, completion: @escaping NftListCompletion) {
        let request = GetNftListRequest(ids: ids)
        
        networkClient.send(request: request, type: [Nft].self) { [weak self] result in
            switch result {
            case .success(let nfts):
                nfts.forEach { nft in
                    self?.storage.saveNft(nft)
                }
                completion(.success(nfts))
            case .failure(let error):
                if let ids = ids, !ids.isEmpty {
                    let cachedNfts = ids.compactMap { self?.storage.getNft(with: $0) }
                    if !cachedNfts.isEmpty {
                        completion(.success(cachedNfts))
                    } else {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
