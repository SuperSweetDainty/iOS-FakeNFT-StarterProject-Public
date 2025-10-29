//
//  CatalogCollectionViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 09.10.2025.
//

import UIKit
import ProgressHUD

protocol CatalogCollectionViewControllerProtocol: AnyObject {
    func displayCollections(_ collections: [NftCellModel])
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showEmptyState()
    func showContentState()
    func updateNFTLikeState(at index: Int, isLiked: Bool)
    func updateNFTCartState(at index: Int, isInCart: Bool)
}


final class CatalogCollectionViewController: UIViewController, CatalogCollectionViewControllerProtocol {
    
    // MARK: - Private Properties
    private var collectionDetails: CatalogCollectionNft
    private var presenter: CatalogCollectionViewPresenterProtocol
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 20, right: 16)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 9
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        collectionView.register(
            CatalogNftCollectionViewCell.self,
            forCellWithReuseIdentifier: CatalogNftCollectionViewCell.identifier
        )
        collectionView.register(CatalogCollectionSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CatalogCollectionSectionHeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyState)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "В коллекции пока нет NFT"
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "попробуйте позже или обновите коллекцию"
        label.font = UIFont.caption1
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Попробовать снова", for: .normal)
        button.titleLabel?.font = UIFont.bodyBold
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateTitleLabel, emptyStateMessageLabel, retryButton])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(named: "nav_back_button"), for: .normal)
        button.addTarget(self,
                             action: #selector(backButtonTapped),
                             for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    // MARK: - Init
    init(collectionDetails: CatalogCollectionNft) {
        self.collectionDetails = collectionDetails
        let servicesAssembly = ServicesAssembly(
            networkClient: DefaultNetworkClient(),
            nftStorage: NftStorageImpl()
        )
        
        self.presenter = CatalogCollectionViewPresenter(
            collectionDetails: collectionDetails,
            profileService: servicesAssembly.profileService,
            nftService: servicesAssembly.nftService
        )
        
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - IB Actions
    @objc private func retryButtonTapped() {
        presenter.didTapRetry()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Public Methods
    func displayCollections(_ collections: [NftCellModel]) {
        collectionView.reloadData()
        showContentState()
    }
    
    func showLoading(){
        ProgressHUD.animate()
        
        collectionView.isHidden = true
        emptyStateStack.isHidden = true
    }
    
    func hideLoading() {
        ProgressHUD.dismiss()
    }
    
    func showError(_ message: String) {
        emptyStateStack.isHidden = false
        collectionView.isHidden = true
        emptyStateTitleLabel.text = "Ошибка загрузки"
        emptyStateMessageLabel.text = message
    }
    
    func showEmptyState() {
        emptyStateStack.isHidden = false
        collectionView.isHidden = true
        emptyStateTitleLabel.text = "В коллекции пока нет NFT"
    }
    
    func showContentState() {
        emptyStateStack.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func updateNFTLikeState(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func updateNFTCartState(at index: Int, isInCart: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: - Private Methods
    private func setupUI(){
        configureView()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        [collectionView, emptyStateStack, backButton].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //CollectionView
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //Empty State ImageView
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Empty State Stack
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Back Button
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9)
        ])
    }
    
    private func animateForButton(at index: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CatalogNftCollectionViewCell else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
    
    private func openAuthorWebsite() {
        let webViewVC = WebViewViewController()
        
        if let url = URL(string: WebViewConstants.authorURLString) {
            let request = URLRequest(url: url)
            webViewVC.load(request: request)
        }
        
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}

extension CatalogCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.collectionsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CatalogNftCollectionViewCell.identifier,
            for: indexPath) as? CatalogNftCollectionViewCell else {
            return UICollectionViewCell()
        }
        let nft = presenter.collection(at: indexPath.item)
        cell.configure(with: nft)
        
        cell.onFavoriteButtonTapped = { [weak self] in
            self?.presenter.didTapLike(for: nft.id)
            self?.animateForButton(at: indexPath.item)
        }
        
        cell.onCartButtonTapped = { [weak self] in
            self?.presenter.didTapCart(for: nft.id)
            self?.animateForButton(at: indexPath.item)
        }
        
        return cell
    }
}

extension CatalogCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 450)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let left: CGFloat = 16
        let right: CGFloat = 16
        let spacing: CGFloat = 9
        let columns: CGFloat = 3
        let totalSpacing = left + right + spacing * (columns - 1)
        let cellWidth = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: cellWidth, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CatalogCollectionSectionHeaderView.identifier,
                for: indexPath
            ) as? CatalogCollectionSectionHeaderView else {
                return UICollectionReusableView()
            }
            header.configure(with: collectionDetails)
            
            header.onAuthorTap = { [weak self] in
                self?.openAuthorWebsite()
            }
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let nft = presenter.collection(at: indexPath.item)
        
        let networkClient = DefaultNetworkClient()
        let nftStorage = NftStorageImpl()
        
        let servicesAssembler = ServicesAssembly(
            networkClient: networkClient,
            nftStorage: nftStorage
        )
        let nftDetailAssembly = NftDetailAssembly(servicesAssembler: servicesAssembler)
        
        let input = NftDetailInput(id: nft.id)
        
        let detailNftVC = nftDetailAssembly.build(with: input)
        
        detailNftVC.modalPresentationStyle = .fullScreen
        present(detailNftVC, animated: true)
    }
}

extension CatalogCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
}

extension Notification.Name {
    static let nftLikeStateChanged = Notification.Name("NFTLikeStateChanged")
    static let nftCartStateChanged = Notification.Name("NFTCartStateChanged")
    static let nftCartCleared = Notification.Name("CartShouldBeCleared")
}
