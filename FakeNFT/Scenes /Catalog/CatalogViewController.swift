//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 06.10.2025.
//

import UIKit
import ProgressHUD

import UIKit
import ProgressHUD

protocol CatalogViewControllerProtocol: AnyObject {
    func displayCollections(_ collections: [CatalogCollectionNft])
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showEmptyState()
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol, ErrorView {
    //MARK: - Public Properties
    var presenter: CatalogViewPresenterProtocol?
    
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
        label.text = "Коллекций пока нету"
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CatalogViewPresenter()
        presenter?.view = self
        setupUI()
        presenter?.viewDidLoad()
    }
    
    //MARK: - IB Actions
    @objc private func didTappedSortButton(){
        let alertSort = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        for option in SortOption.allCases {
            alertSort.addAction(UIAlertAction(
                title: option.title,
                style: .default
            ) { [weak self] _ in
                self?.presenter?.didSelectSortOption(option)
            })
        }
        
        alertSort.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(alertSort, animated: true)
    }
    
    @objc private func retryButtonTapped() {
        presenter?.didTapRetry()
    }
    
    //MARK: - Public Methods
    func displayCollections(_ collections: [CatalogCollectionNft]) {
        catalogTableView.reloadData()
        showContentState()
    }
    
    func showLoading(){
        ProgressHUD.show()
        
        catalogTableView.isHidden = true
        emptyStateStack.isHidden = true
    }
    
    func hideLoading() {
        ProgressHUD.dismiss()
    }
    
    func showError(_ message: String){
        let errorModel = ErrorModel(
            message: "Нет подключения к интернету",
            actionText: "Попробовать снова",
            action: { [weak self] in
                self?.presenter?.didTapRetry()
            }
        )
        showError(errorModel)
    }
    
    func showEmptyState() {
        emptyStateStack.isHidden = false
        catalogTableView.isHidden = true
    }
    
    // MARK: - Private Methods
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
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showContentState() {
        emptyStateStack.isHidden = true
        catalogTableView.isHidden = false
        catalogTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         presenter?.collectionsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CatalogTableViewCell else {
            return UITableViewCell()
        }
        
        // TODO: - Заглушка данных
        guard let presenter = presenter,
              indexPath.row < presenter.collectionsCount else {
            return cell
        }
        
        let collection = presenter.collection(at: indexPath.row)
        cell.configure(with: collection)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        179
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let collection = presenter?.collection(at: indexPath.row) else { return }
        let collectionVC = CatalogCollectionViewController(collectionDetails: collection)
        navigationController?.pushViewController(collectionVC, animated: true)
    }
}
