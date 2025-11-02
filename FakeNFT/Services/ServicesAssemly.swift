final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let imageCacheServiceInstance: ImageCacheService

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.imageCacheServiceInstance = ImageCacheServiceImpl()
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var cartNetworkClient: NetworkClient {
        networkClient
    }
    
    var profileService: ProfileService {
        ProfileServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var imageCacheService: ImageCacheService {
        imageCacheServiceInstance
    }
}
