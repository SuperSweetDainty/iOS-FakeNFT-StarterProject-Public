import Foundation

protocol ProfileService {
    func loadProfile(completion: @escaping (Result<User, Error>) -> Void)
    func updateProfile(_ user: User, completion: @escaping (Result<User, Error>) -> Void)
}

final class ProfileServiceImpl: ProfileService {
    
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func loadProfile(completion: @escaping (Result<User, Error>) -> Void) {
        // TODO: Implement actual network request
        // For now, return mock data
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
            let mockUser = User(
                id: "1",
                name: "Иван Иванов",
                description: "Дизайнер, создатель NFT",
                avatar: URL(string: "https://example.com/avatar.jpg"),
                website: URL(string: "https://example.com"),
                nfts: ["1", "2", "3"],
                likes: ["4", "5", "6"]
            )
            DispatchQueue.main.async {
                completion(.success(mockUser))
            }
        }
    }
    
    func updateProfile(_ user: User, completion: @escaping (Result<User, Error>) -> Void) {
        // TODO: Implement actual network request
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
            DispatchQueue.main.async {
                completion(.success(user))
            }
        }
    }
}
