//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 06.10.2025.
//

import UIKit


final class CatalogViewController: UIViewController {
    
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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        view.addSubview(catalogTableView)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            catalogTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            catalogTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            catalogTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            catalogTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
                                         
    //MARK: - Actions
    @objc private func didTappedSortButton(){
            //TODO: вернусь позже
        }
}


extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 // TODO: - тест
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CatalogTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? CatalogTableViewCell else {
                    return UITableViewCell()
                }
                
                // TODO: -Заглушка данных
                let mockData = (name: "Коллекция \(indexPath.row + 1)", nftCount: indexPath.row * 3 + 1)
                cell.configure(with: mockData.name, nftCount: mockData.nftCount)
                
                return cell
            }
    }

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 156
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: - добавить тап по коллекции
        print("Selected collection at index: \(indexPath.row)")
    }
}

