//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 06.10.2025.
//

import UIKit
import ProgressHUD


final class CatalogViewController: UIViewController {
    // MARK: - Private properties
    private var collectionsNft: [CatalogCollectionNft] = []
    private var currentSortOption: SortOption = .byName {
        didSet {
            applySorting()
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var catalogTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: "CatalogTableViewCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .background
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyState)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Не удалось загрузить коллекции"
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "проверьте подключение к интернету"
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCollections()
    }
    
    private func setupNavigationBar(){
        let sortButton = UIBarButtonItem(
                   image: UIImage(named: "sortButtonImage") ?? UIImage(systemName: "arrow.up.arrow.down"),
                   style: .plain,
                   target: self,
                   action: #selector(didTappedSortButton)
               )
               sortButton.tintColor = .black
               navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupUI(){
        configureView()
        setupNavigationBar()
        addSubviews()
        setupConstraints()
    }
    
    private func configureView(){
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews(){
        [catalogTableView, emptyStateStack].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            //Catalog TableView
            catalogTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            catalogTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            catalogTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            catalogTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            //Empty State ImageView
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Empty State Stack
            emptyStateStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 331)
        ])
    }
    
    private func loadCollections() {
            // Показываем индикатор загрузки
            ProgressHUD.show()
            
            catalogTableView.isHidden = true
            emptyStateStack.isHidden = true
            
            // Имитация сетевого запроса (2 секунды)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ProgressHUD.dismiss() // Скрываем индикатор
//                
//                // TODO: TEST 1 Успешная загрузка с данными
                self.collectionsNft = self.createMockCollections()
                self.showContentState()
                
//                // TODO: TEST 2 Ошибка загрузки
//                 self.collectionsNft = []
//                 self.showEmptyState()
            }
        }
    
    private func showEmptyState() {
           emptyStateStack.isHidden = false
           catalogTableView.isHidden = true
       }
       
       private func showContentState() {
           emptyStateStack.isHidden = true
           catalogTableView.isHidden = false
           catalogTableView.reloadData()
       }
    
    private func applySorting() {
        collectionsNft = currentSortOption.sortCollections(collectionsNft)
        catalogTableView.reloadData()
    }
    
    // MARK: - Mock
        private func createMockCollections() -> [CatalogCollectionNft] {
            return [
                CatalogCollectionNft(id: "1", name: "Коллекция 1", nftCount: 5, imageURL: "collectionOne"),
                CatalogCollectionNft(id: "2", name: "Коллекция 2", nftCount: 3,  imageURL: "collectionTwo"),
                CatalogCollectionNft(id: "3", name: "Коллекция 3", nftCount: 7,  imageURL: "collectionThree"),
                CatalogCollectionNft(id: "4", name: "Коллекция 4", nftCount: 2,  imageURL:  "collectionOne"),
                CatalogCollectionNft(id: "5", name: "Коллекция 5", nftCount: 8,  imageURL: "collectionThree")
            ]
        }
    
                                         
    //MARK: - Actions
    @objc private func didTappedSortButton(){
        let alertSort = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        alertSort.addAction(UIAlertAction(title: "По названию", style: .default) { _ in
            self.currentSortOption = .byName
        })
        alertSort.addAction(UIAlertAction(title: "По количеству NFT", style: .default) { _ in
            self.currentSortOption = .byNftCount
        })
        alertSort.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(alertSort, animated: true)
        }
    
    @objc private func retryButtonTapped() {
        //TODO: - добавить логику
    }
}


extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionsNft.count // TODO: - тест
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? CatalogTableViewCell else {
                    return UITableViewCell()
                }
                
        // TODO: - Заглушка данных
        let collection = collectionsNft[indexPath.row]
        cell.configure(with: collection)
        
        return cell
    }
    }

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 179
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: - добавить тап по коллекции
        print("Selected collection at index: \(indexPath.row)")
    }
}

