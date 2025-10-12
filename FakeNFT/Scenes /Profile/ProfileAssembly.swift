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
        
        // Wrap in navigation controller for navigation support
        let navigationController = UINavigationController(rootViewController: viewController)
        
        // Hide navigation bar for all screens (no titles needed per design)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        return navigationController
    }
}
