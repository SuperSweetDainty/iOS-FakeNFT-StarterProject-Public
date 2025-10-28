import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly?
    
    private let profileTabBarItem = UITabBarItem(
        title: "Профиль",
        image: UIImage(resource: .profileTabBarItem),
        tag: 0
    )
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 1
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(resource: .basket).withTintColor(.segmentActive),
        tag: 2
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogController = CatalogViewController()
        catalogController.tabBarItem = catalogTabBarItem
        
        guard let servicesAssembly = servicesAssembly else {
            fatalError("ServicesAssembly not initialized")
        }
        
        let cartController = CartController(
            servicesAssembly: servicesAssembly
        )
        
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        cartNavigationController.tabBarItem = cartTabBarItem
        
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        let profileAssembly = ProfileAssembly(servicesAssembler: servicesAssembly)
        let profileController = profileAssembly.build(with: ProfileInput())
        profileController.tabBarItem = profileTabBarItem
        
        viewControllers = [profileController, catalogNavigationController, cartNavigationController]
        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = .segmentActive
    }
}
