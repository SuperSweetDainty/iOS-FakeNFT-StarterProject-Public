import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: "Профиль",
        image: UIImage(resource: .profileTabBarItem),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let profileAssembly = ProfileAssembly(servicesAssembler: servicesAssembly)
        let profileController = profileAssembly.build(with: ProfileInput())
        profileController.tabBarItem = profileTabBarItem

        viewControllers = [catalogController, profileController]

        view.backgroundColor = .systemBackground
    }
}
