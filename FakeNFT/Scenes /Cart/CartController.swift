//
//  CartController.swift
//  FakeNFT
//
//  Created by R Kolos on 4/10/25.
//

import UIKit

final class CartController: UIViewController, UpdateCartProtocol {
    // MARK: - Properties
    private var arrayNfts: [Nft] = []
    private var presenter: PresenterCartProtocol?
    private var servicesAssembly: ServicesAssembly
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var sortButton: UIButton = {
        let sortButton = UIButton()
        sortButton.setImage(UIImage(resource: .filter), for: .normal)
        sortButton.tintColor = .segmentActive
        sortButton.addTarget(self, action: #selector(Self.cartSorting), for: .touchUpInside)
        return sortButton
    }()
    
    private var thePayView: UIView = {
        let thePayView = UIView()
        thePayView.backgroundColor = .segmentInactive
        thePayView.layer.cornerRadius = 12
        thePayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thePayView.clipsToBounds = true
        return thePayView
    }()
    
    private lazy var thePayButton: UIButton = {
        let thePayButton = UIButton()
        thePayButton.setTitle("К оплате", for: .normal)
        thePayButton.titleLabel?.font = .bodyBold
        thePayButton.setTitleColor(.white, for: .normal)
        thePayButton.backgroundColor = .segmentActive
        thePayButton.layer.cornerRadius = 16
        thePayButton.addTarget(self, action: #selector(Self.forPayment), for: .touchUpInside)
        return thePayButton
    }()
    
    private var costAllNft: UILabel = {
        let costAllNft = UILabel()
        costAllNft.font = .bodyBold
        costAllNft.textColor = .greenUniversal
        return costAllNft
    }()
    
    private var nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .textActive
        return label
    }()
    
    private var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Корзина пуста"
        label.textColor = .textActive
        label.font = .bodyBold
        return label
    }()
    
    // MARK: - init
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
        self.presenter = CartPresenter(view: self, networkService: servicesAssembly.cartNetworkClient, cartService: CartService.shared, nftService: servicesAssembly.nftService)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        if arrayNfts.isEmpty {
        //            pageReload()
        //        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // перезагружаем корзину каждый раз, когда экран снова показан
        (presenter as? CartPresenter)?.reloadCart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Methods
    private func setupCart() {
        view.addSubview(tableView)
        view.addSubview(sortButton)
        thePayView.addSubview(nftCountLabel)
        thePayView.addSubview(costAllNft)
        thePayView.addSubview(thePayButton)
        view.addSubview(thePayView)
        view.addSubview(emptyStateLabel)
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        nftCountLabel.translatesAutoresizingMaskIntoConstraints = false
        costAllNft.translatesAutoresizingMaskIntoConstraints = false
        thePayButton.translatesAutoresizingMaskIntoConstraints = false
        thePayView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            sortButton.heightAnchor.constraint(equalToConstant: 42),
            sortButton.widthAnchor.constraint(equalToConstant: 42),
            
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 4),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: thePayView.topAnchor),
            
            thePayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            thePayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thePayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thePayView.heightAnchor.constraint(equalToConstant: 76),
            
            nftCountLabel.topAnchor.constraint(equalTo: thePayView.topAnchor,constant: 16),
            nftCountLabel.leadingAnchor.constraint(equalTo: thePayView.leadingAnchor,constant: 16),
            
            costAllNft.topAnchor.constraint(equalTo: nftCountLabel.bottomAnchor,constant: 2),
            costAllNft.bottomAnchor.constraint(equalTo: thePayView.bottomAnchor,constant: -16),
            costAllNft.leadingAnchor.constraint(equalTo: thePayView.leadingAnchor,constant: 16),
            
            thePayButton.heightAnchor.constraint(equalToConstant: 44),
            thePayButton.trailingAnchor.constraint(equalTo: thePayView.trailingAnchor, constant: -16),
            thePayButton.centerYAnchor.constraint(equalTo: thePayView.centerYAnchor),
            thePayButton.widthAnchor.constraint(equalToConstant: 240),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateTotalLabels() {
        nftCountLabel.text = "\(arrayNfts.count) NFT"
        let price = arrayNfts.reduce(into: 0) {$0 += $1.price}
        costAllNft.text = String(format: "%.2f", price) + " ETH"
    }
    
    func pageReload() {
        let state = arrayNfts.isEmpty
        sortButton.isHidden = state
        tableView.isHidden = state
        thePayView.isHidden = state
        emptyStateLabel.isHidden = !state
        updateTotalLabels()
        tableView.reloadData()
    }
    
    func nftUpdate(with nfts: [Nft]) {
        self.arrayNfts = nfts
        pageReload()
    }
    
    @objc
    private func cartSorting() {
        let alertController = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        let cartSortByPrice = UIAlertAction(title: "По цене", style: .default) { _ in
            self.arrayNfts.sort { $0.price > $1.price }
            self.pageReload()
        }
        let cartSortByRating = UIAlertAction(title: "По рейтингу", style: .default) { _ in
            self.arrayNfts.sort { $0.rating > $1.rating }
            self.pageReload()
        }
        let cartSortByName = UIAlertAction(title: "По названию", style: .default) { _ in
            self.arrayNfts.sort { $0.name > $1.name }
            self.pageReload()
        }
        let sortCancel = UIAlertAction(title: "Закрыть", style: .cancel)
        
        alertController.addAction(cartSortByPrice)
        alertController.addAction(cartSortByRating)
        alertController.addAction(cartSortByName)
        alertController.addAction(sortCancel)
        present(alertController, animated: true)
    }
    
    @objc
    private func forPayment() {
        let payChoosingVC = PayChoosingController(nfts: arrayNfts, servicesAssembly: servicesAssembly) { [weak self] in
            self?.arrayNfts.removeAll()
            self?.pageReload()
        }
        payChoosingVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .chevronBackward),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        payChoosingVC.navigationItem.leftBarButtonItem?.tintColor = .segmentActive
        
        navigationController?.pushViewController(payChoosingVC, animated: true)
    }
    
    
    @objc
    private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension CartController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayNfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseIdentifier, for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        cell.setupCell(with: arrayNfts[indexPath.row],delegate: self)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - Extension CartController
extension CartController: CellCartProtocol {
    func present(with id: String, image: UIImage) {
        let deleteVC = DeleteCartController()
        deleteVC.modalPresentationStyle = .overFullScreen
        deleteVC.modalTransitionStyle = .crossDissolve
        deleteVC.onDelete = { [weak self] in
            CartService.shared.removeFromCart(nftId: id)
            self?.arrayNfts.removeAll { $0.id == id }
            self?.pageReload()
        }
        deleteVC.setupImage(image)
        present(deleteVC, animated: true)
    }
}
