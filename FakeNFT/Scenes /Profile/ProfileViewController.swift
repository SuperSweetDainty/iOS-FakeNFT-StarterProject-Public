import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter: ProfilePresenter
    private let servicesAssembly: ServicesAssembly
    private var user: User?
    var currentAvatarImage: UIImage?
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        // Register cells
        tableView.register(ProfileHeaderCell.self)
        tableView.register(ProfileMenuCell.self)
        
        return tableView
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(presenter: ProfilePresenter, servicesAssembly: ServicesAssembly) {
        self.presenter = presenter
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupNotifications()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user != nil {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [tableView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        tableView.isHidden = true
        activityIndicator.startAnimating()
        
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = nil
        navigationItem.hidesBackButton = true
        
        let editButton = UIBarButtonItem(
            image: UIImage(resource: .editButton),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        editButton.tintColor = UIColor(hexString: "1A1B22")
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileDidUpdate(_:)),
            name: .profileDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(avatarDidChange(_:)),
            name: .avatarDidChange,
            object: nil
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - ProfileView

extension ProfileViewController: ProfileView {
    
    func displayProfile(_ user: User) {
        self.user = user
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.tableView.isHidden = false
            self?.tableView.reloadData()
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func showEmptyState() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
            
            let alert = UIAlertController(
                title: "Профиль не найден",
                message: "Не удалось загрузить данные профиля",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
                self?.activityIndicator.startAnimating()
                self?.tableView.isHidden = true
                self?.presenter.viewDidLoad()
            })
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }
    
    func showWebView(with url: URL) {
        let webViewController = WebViewController(url: url)
        let navigationController = UINavigationController(rootViewController: webViewController)
        present(navigationController, animated: true)
    }
    
    func presentEditProfile(_ viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    func dismissEditProfile() {
        dismiss(animated: true)
    }
    
    func updateAvatar(_ image: UIImage?) {
        // Update the avatar in ProfileHeaderCell
        DispatchQueue.main.async { [weak self] in
            self?.currentAvatarImage = image
            self?.updateAvatarInHeaderCell(image)
        }
    }
    
    private func updateAvatarInHeaderCell(_ image: UIImage?) {
        if let headerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCell {
            headerCell.updateAvatar(image)
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func profileDidUpdate(_ notification: Notification) {
        guard let userDict = notification.object as? [String: User],
              let updatedUser = userDict["user"] else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.user = updatedUser
            self?.tableView.reloadData()
        }
    }
    
    @objc private func avatarDidChange(_ notification: Notification) {
        guard let imageDict = notification.object as? [String: Any] else { return }
        
        DispatchQueue.main.async { [weak self] in
            if let newAvatarImage = imageDict["image"] as? UIImage {
                self?.currentAvatarImage = newAvatarImage
                self?.updateAvatarInHeaderCell(newAvatarImage)
            } else if imageDict["image"] is NSNull {
                self?.currentAvatarImage = nil
                self?.updateAvatarInHeaderCell(nil)
            }
        }
    }
    
    @objc private func editButtonTapped() {
        presenter.didTapEditProfile()
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Header section + Menu section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Header cell
        case 1: return 2 // My NFTs + Favorite NFTs
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: ProfileHeaderCell = tableView.dequeueReusableCell()
            if let user = user {
                cell.configure(
                    with: user,
                    onWebsiteTap: { [weak self] in
                        self?.presenter.didTapWebsite()
                    }
                )
                
                if let currentAvatarImage = currentAvatarImage {
                    cell.updateAvatar(currentAvatarImage)
                } else {
                    cell.updateAvatar(nil)
                }
            }
            return cell
            
        case 1:
            let cell: ProfileMenuCell = tableView.dequeueReusableCell()
            let title = indexPath.row == 0 ? "Мои NFT" : "Избранные NFT"
            cell.configure(with: title)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                presenter.didTapMyNFTs()
            } else {
                presenter.didTapFavoriteNFTs()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 50
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        case 1:
            return 50
        default:
            return 44
        }
    }
}

// MARK: - ProfileView Extension

extension ProfileViewController {
    
    func navigateToMyNFTs() {
        let presenter = MyNFTPresenterImpl(servicesAssembly: servicesAssembly)
        let myNFTViewController = MyNFTViewController(servicesAssembly: servicesAssembly, presenter: presenter)
        presenter.view = myNFTViewController
        navigationController?.pushViewController(myNFTViewController, animated: true)
    }
    
    func navigateToFavoriteNFTs() {
        let presenter = FavoritesNFTPresenterImpl(servicesAssembly: servicesAssembly)
        let favoritesNFTViewController = FavoritesNFTViewController(servicesAssembly: servicesAssembly, presenter: presenter)
        presenter.view = favoritesNFTViewController
        navigationController?.pushViewController(favoritesNFTViewController, animated: true)
    }
}

