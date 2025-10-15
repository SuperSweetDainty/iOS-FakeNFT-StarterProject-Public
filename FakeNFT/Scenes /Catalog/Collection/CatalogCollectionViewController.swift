//
//  CatalogCollectionViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 09.10.2025.
//

import UIKit
import ProgressHUD


final class CatalogCollectionViewController: UIViewController {
    
    // MARK: - Private Properties
    //private let collectionId: String
    private var collectionDetails: CatalogCollectionNft
    private var nftCollectionCell: [NftCellModel] = []
    
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
    
    // MARK: - Init
    init(collectionDetails: CatalogCollectionNft) {
        self.collectionDetails = collectionDetails
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadNFTs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Public Methods
    func displayCollections(_ collections: [NftCellModel]) {
        collectionView.reloadData()
        showContentState()
    }
    
    private func setupUI(){
        configureView()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        [collectionView, emptyStateStack].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //Empty State ImageView
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Empty State Stack
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadNFTs() {
        showLoading()
        
        // Имитация загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            let shouldFail = false // Для теста ошибка true
            let isEmptyCollection = false // true - пустая коллекция
            
            if shouldFail {
                self.showError("Нет удалось загрузить коллекцию")
            }  else if isEmptyCollection {
                self.nftCollectionCell = [] // Пустая коллекция
                self.showEmptyState()
            } else {
                self.nftCollectionCell = self.createMockNftCollections()
                self.showContentState()
            }
            
            self.hideLoading()
        }
    }
    
    func showLoading(){
        ProgressHUD.show()
        
        collectionView.isHidden = true
        emptyStateStack.isHidden = true
    }
    
    func hideLoading() {
        ProgressHUD.dismiss()
    }
    
    private func showError(_ message: String) {
        emptyStateStack.isHidden = false
        collectionView.isHidden = true
        emptyStateTitleLabel.text = "Ошибка загрузки"
        emptyStateMessageLabel.text = message
    }
    
    @objc private func retryButtonTapped() {
        loadNFTs()
    }
    
    
    func showEmptyState() {
        emptyStateStack.isHidden = false
        collectionView.isHidden = true
        emptyStateTitleLabel.text = "В коллекции пока нет NFT"
    }
    
    private func showContentState() {
        emptyStateStack.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    private func handleLike(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        // Инвертируем состояние лайка
        nftCollectionCell[index].isFavorite.toggle()
        
        // Обновляем только нужную ячейку
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        
        // Сохраняем состояние лайка (мок-реализация)
        saveLikeState(nftId: nftId, isLiked: nftCollectionCell[index].isFavorite)
        
        // Анимация для обратной связи
        animateForButton(at: index)
    }
    
    private func saveLikeState(nftId: String, isLiked: Bool) {
        // TODO: Заменить на реальное сохранение в сторедж/сервер
        print("NFT \(nftId) like state: \(isLiked ? "liked" : "unliked")")
        
        // Мок-сохранение в UserDefaults
        UserDefaults.standard.set(isLiked, forKey: "nft_like_\(nftId)")
    }
    
    private func loadLikeState(nftId: String) -> Bool {
        // TODO: Заменить на реальную загрузку из стореджа/сервера
        return UserDefaults.standard.bool(forKey: "nft_like_\(nftId)")
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
    
    private func handleCart(for nftId: String) {
        guard let index = nftCollectionCell.firstIndex(where: { $0.id == nftId }) else { return }
        
        // Инвертируем состояние лайка
        nftCollectionCell[index].isInCart.toggle()
        
        // Обновляем только нужную ячейку
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        
        // Сохраняем состояние лайка (мок-реализация)
        saveCartState(nftId: nftId, isInCart: nftCollectionCell[index].isFavorite)
        
        // Анимация для обратной связи
        animateForButton(at: index)
    }
    
    private func saveCartState(nftId: String, isInCart: Bool) {
        // TODO: Заменить на реальное сохранение в сторедж/сервер
        print("NFT \(nftId) like state: \(isInCart ? "cart" : "noCart")")
        
        // Мок-сохранение в UserDefaults
        UserDefaults.standard.set(isInCart, forKey: "nft_cart_\(nftId)")
    }
    
    private func loadCartState(nftId: String) -> Bool {
        // TODO: Заменить на реальную загрузку
        return UserDefaults.standard.bool(forKey: "nft_cart_\(nftId)")
    }
    
    
    // MARK: - Mock
    private func createMockNftCollections() -> [NftCellModel] {
        let mockNFTs = [
            NftCellModel(id: "1", name: "Archie", images: "nftCardsOne", rating: 2, price: 1, isFavorite: true, isInCart: false),
            NftCellModel(id: "2", name: "Ruby", images: "nftCardsTwo", rating: 2, price: 2, isFavorite: true, isInCart: true),
            NftCellModel(id: "3", name: "Nacho", images: "nftCardsThree", rating: 3, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "4", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "5", name: "Daisy", images: "nftCardsThree", rating: 1, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "6", name: "Susan", images: "nftCardsTwo", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "7", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
        ]
        return mockNFTs.map { nft in
            var updatedNft = nft
            updatedNft.isFavorite = loadLikeState(nftId: nft.id)
            updatedNft.isInCart = loadCartState(nftId: nft.id)
            return updatedNft
        }
    }
}

extension CatalogCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nftCollectionCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //TODO: -Заглушка данных
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CatalogNftCollectionViewCell.identifier,
            for: indexPath) as? CatalogNftCollectionViewCell else {
            return UICollectionViewCell()
        }
        let nft = nftCollectionCell[indexPath.item]
        cell.configure(with: nft)
        
        cell.onFavoriteButtonTapped = { [weak self] in
            self?.handleLike(for: nft.id)
        }
        
        cell.onCartButtonTapped = { [weak self] in
            self?.handleCart(for: nft.id)
        }
        
        return cell
    }
    
    
}

extension CatalogCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Временная фиксированная высота, можно сделать динамической позже
        return CGSize(width: collectionView.frame.width, height: 450)
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
    
    private func openAuthorWebsite() {
        let webViewVC = WebViewViewController()
        
        // Создаем URL запрос для сайта Практикума
        if let url = URL(string: WebViewConstants.authorURLString) {
            let request = URLRequest(url: url)
            webViewVC.load(request: request)
        }
        
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}
