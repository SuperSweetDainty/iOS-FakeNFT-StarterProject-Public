import Foundation

extension Notification.Name {
    static let profileDidUpdate = Notification.Name("profileDidUpdate")
    static let avatarDidChange = Notification.Name("avatarDidChange")
}

protocol ProfileService {
    func loadProfile(completion: @escaping (Result<User, Error>) -> Void)
    func updateProfile(name: String?, description: String?, website: String?, completion: @escaping (Result<User, Error>) -> Void)
    func updateLikes(_ likes: [String], completion: @escaping (Result<User, Error>) -> Void)
}

final class ProfileServiceImpl: ProfileService {
    
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func loadProfile(completion: @escaping (Result<User, Error>) -> Void) {
        let request = GetProfileRequest(profileId: "1")
        
        networkClient.send(request: request, type: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.storage.saveProfile(user)
                completion(.success(user))
            case .failure(let error):
                if let cachedUser = self?.storage.getProfile() {
                    completion(.success(cachedUser))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateProfile(name: String?, description: String?, website: String?, completion: @escaping (Result<User, Error>) -> Void) {
        let dto = UpdateProfileDto(
            name: name,
            description: description,
            website: website,
            likes: nil
        )
        
        let request = UpdateProfileRequest(profileId: "1", profileDto: dto)
        
        networkClient.send(request: request, type: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.storage.saveProfile(user)
                
                NotificationCenter.default.post(
                    name: .profileDidUpdate,
                    object: nil,
                    userInfo: ["user": user]
                )
                
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateLikes(_ likes: [String], completion: @escaping (Result<User, Error>) -> Void) {
        let dto = UpdateProfileDto(
            name: nil,
            description: nil,
            website: nil,
            likes: likes
        )
        
        let request = UpdateProfileRequest(profileId: "1", profileDto: dto)
        
        networkClient.send(request: request, type: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.storage.saveProfile(user)
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
