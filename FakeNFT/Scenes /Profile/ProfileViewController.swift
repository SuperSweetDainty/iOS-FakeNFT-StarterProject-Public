import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let presenter: ProfilePresenter
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
    
    init(presenter: ProfilePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        presenter.viewDidLoad()
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
        
        // Initially hide table view and show loading indicator
        tableView.isHidden = true
        activityIndicator.startAnimating()
        
        setupConstraints()
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
            // Hide loading indicator and show table view
            self?.activityIndicator.stopAnimating()
            self?.tableView.isHidden = false
            self?.tableView.reloadData()
        }
    }
    
    func showEmptyState() {
        DispatchQueue.main.async { [weak self] in
            // Hide loading indicator
            self?.activityIndicator.stopAnimating()
            
            let alert = UIAlertController(
                title: "Профиль не найден",
                message: "Не удалось загрузить данные профиля",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
                // Show loading indicator again and restart loading
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
        // Find the ProfileHeaderCell and update its avatar
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
                // Avatar was changed to a new image
                self?.currentAvatarImage = newAvatarImage
                self?.updateAvatarInHeaderCell(newAvatarImage)
            } else if imageDict["image"] is NSNull {
                // Avatar was removed
                self?.currentAvatarImage = nil
                self?.updateAvatarInHeaderCell(nil)
            }
        }
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
                    onEditTap: { [weak self] in
                        self?.presenter.didTapEditProfile()
                    },
                    onWebsiteTap: { [weak self] in
                        self?.presenter.didTapWebsite()
                    }
                )
                
                // Apply current avatar image if available, otherwise let configure handle it
                if let currentAvatarImage = currentAvatarImage {
                    cell.updateAvatar(currentAvatarImage)
                } else {
                    // Ensure system icon is set when no current avatar
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
        let myNFTViewController = MyNFTViewController()
        navigationController?.pushViewController(myNFTViewController, animated: true)
    }
    
    func navigateToFavoriteNFTs() {
        let favoritesNFTViewController = FavoritesNFTViewController()
        navigationController?.pushViewController(favoritesNFTViewController, animated: true)
    }
}

