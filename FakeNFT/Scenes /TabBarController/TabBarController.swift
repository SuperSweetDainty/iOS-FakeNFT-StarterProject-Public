import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(resource: .basket).withTintColor(.segmentActive),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogController = CatalogViewController()
        catalogController.tabBarItem = catalogTabBarItem
        
        let cartController = CartController(
            servicesAssembly: servicesAssembly
        )
        
        let navigationController = UINavigationController(rootViewController: cartController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.tabBarItem = cartTabBarItem

        viewControllers = [catalogController, navigationController]
            
        let catalogNC = UINavigationController(rootViewController: catalogController)

        viewControllers = [catalogNC]

        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = .segmentActive
        view.backgroundColor = .systemBackground
    }
}
