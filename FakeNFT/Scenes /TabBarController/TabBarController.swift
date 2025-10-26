//import UIKit
//
//final class TabBarController: UITabBarController {
//    
//    var servicesAssembly: ServicesAssembly!
//    
//    private let catalogTabBarItem = UITabBarItem(
//        title: NSLocalizedString("Tab.catalog", comment: ""),
//        image: UIImage(systemName: "square.stack.3d.up.fill"),
//        tag: 0
//    )
//    
//<<<<<<< HEAD
//    private let cartTabBarItem = UITabBarItem(
//        title: NSLocalizedString("Tab.cart", comment: ""),
//        image: UIImage(resource: .basket).withTintColor(.segmentActive),
//        tag: 1
//    )
//    
//=======
//    private let profileTabBarItem = UITabBarItem(
//        title: "Профиль",
//        image: UIImage(resource: .profileTabBarItem),
//        tag: 1
//    )
//
//>>>>>>> Laputsin/Profile
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let catalogController = CatalogViewController()
//        catalogController.tabBarItem = catalogTabBarItem
//        
//        let cartController = CartController(
//            servicesAssembly: servicesAssembly
//        )
//<<<<<<< HEAD
//        
//        let cartNavigationController = UINavigationController(rootViewController: cartController)
//        cartNavigationController.tabBarItem = cartTabBarItem
//        
//        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
//        catalogNavigationController.tabBarItem = catalogTabBarItem
//        
//        viewControllers = [catalogNavigationController, cartNavigationController]
//        
//=======
//        catalogController.tabBarItem = catalogTabBarItem
//        
//        let profileAssembly = ProfileAssembly(servicesAssembler: servicesAssembly)
//        let profileController = profileAssembly.build(with: ProfileInput())
//        profileController.tabBarItem = profileTabBarItem
//
//        viewControllers = [catalogController, profileController]
//
//>>>>>>> Laputsin/Profile
//        view.backgroundColor = .systemBackground
//        tabBar.unselectedItemTintColor = .segmentActive
//    }
//}
