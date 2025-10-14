//
//  CatalogCollectionViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 09.10.2025.
//

import UIKit


final class CatalogCollectionViewController: UIViewController {
    
    // MARK: - Private Properties
    //private let collectionId: String
    private var collection: CatalogCollectionNft?
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
    
    // MARK: - Init
    init(collection: CatalogCollectionNft? = nil) {
        self.collection = collection
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
    
    private func setupUI(){
        configureView()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        [collectionView].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadNFTs() {
            nftCollectionCell = createMockCollections()
            collectionView.reloadData()
        }
    
    // MARK: - Mock
    private func createMockCollections() -> [NftCellModel] {
        return [
            NftCellModel(id: "1", name: "Archie", images: "nftCardsOne", rating: 2, price: 1, isFavorite: true, isInCart: false),
            NftCellModel(id: "2", name: "Ruby", images: "nftCardsTwo", rating: 2, price: 2, isFavorite: true, isInCart: true),
            NftCellModel(id: "3", name: "Nacho", images: "nftCardsThree", rating: 3, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "4", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "5", name: "Daisy", images: "nftCardsThree", rating: 1, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "6", name: "Susan", images: "nftCardsTwo", rating: 2, price: 1, isFavorite: false, isInCart: true),
            NftCellModel(id: "7", name: "Biscuit", images: "nftCardsOne", rating: 2, price: 1, isFavorite: false, isInCart: true),
        ]
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
            
            if let collection = collection {
                header.configure(with: collection)
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}
