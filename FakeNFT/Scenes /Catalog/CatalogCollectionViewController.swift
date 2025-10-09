//
//  CatalogCollectionViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 09.10.2025.
//

import UIKit


final class CatalogCollectionViewController: UIViewController {
    
    // MARK: - Private Properties
    private let collectionId: String
    
    // MARK: - Init
    init(collectionId: String) {
        self.collectionId = collectionId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Коллекция \(collectionId)"
        
        // TODO: -Test
        let label = UILabel()
        label.text = "Экран коллекции \(collectionId)\n(Верстка будет в Модуле 2)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
