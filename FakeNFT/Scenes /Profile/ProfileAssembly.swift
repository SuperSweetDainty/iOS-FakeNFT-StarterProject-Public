import UIKit

public final class ProfileAssembly {
    
    private let servicesAssembler: ServicesAssembly
    
    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }
    
    public func build(with input: ProfileInput) -> UIViewController {
        let presenter = ProfilePresenterImpl(
            input: input,
            service: servicesAssembler.profileService
        )
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
