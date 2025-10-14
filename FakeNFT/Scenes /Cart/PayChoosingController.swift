//
//  PayChoosingController.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import UIKit
import ProgressHUD

final class PayChoosingController: UIViewController {
    // MARK: - Properties
    private var coinSelected: Coin?
    private var coins: [Coin] = []
    private var presenter: PayPresenterProtocol?
    
    private lazy var coinCollectionView: UICollectionView = {
        let coinLayout = UICollectionViewFlowLayout()
        let coinCollectionView = UICollectionView(frame: .zero, collectionViewLayout: coinLayout)
        coinCollectionView.backgroundColor = .clear
        coinCollectionView.dataSource = self
        coinCollectionView.delegate = self
        coinCollectionView.isScrollEnabled = false
        coinCollectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.identifier)
        return coinCollectionView
    }()

    private lazy var paymentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .segmentInactive
        return view
    }()

    private lazy var agreementLabel: UILabel = {
        let agreementLabel = UILabel()
        agreementLabel.textAlignment = .left
        agreementLabel.text = "Совершая покупку, вы соглашаетесь с условиями"
        agreementLabel.font = .caption2
        agreementLabel.textColor = .segmentActive
        return agreementLabel
    }()

    private lazy var userAgreementButton: UIButton = {
        let userAgreementButton = UIButton(type: .system)
        userAgreementButton.setTitle("Пользовательского соглашения", for: .normal)
        userAgreementButton.setTitleColor(.blueUniversal, for: .normal)
        userAgreementButton.titleLabel?.font = .caption2
        userAgreementButton.addTarget(self, action: #selector(userAgreementButtonTapped), for: .touchUpInside)
        return userAgreementButton
    }()

    private lazy var payButton: UIButton = {
        let payButton = UIButton()
        payButton.setTitle("Оплатить", for: .normal)
        payButton.titleLabel?.font = .bodyBold
        payButton.setTitleColor(.white, for: .normal)
        payButton.backgroundColor = .segmentActive.withAlphaComponent(0.3)
        payButton.layer.cornerRadius = 16
        payButton.isEnabled = false
        return payButton
    }()

    // MARK: - init
    init(servicesAssembly: ServicesAssembly) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = PayPresenter(view: self, networkService: servicesAssembly.cartNetworkClient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .segmentActive
        navigationItem.title = "Выберите способ оплаты"
        presenter?.viewDidLoad()
        setupConstraints()
            }

    // MARK: - Methods
    private func setupConstraints() {
        view.backgroundColor = .systemBackground
        view.addSubview(coinCollectionView)
        view.addSubview(paymentView)
        paymentView.addSubview(agreementLabel)
        paymentView.addSubview(userAgreementButton)
        paymentView.addSubview(payButton)
        
        coinCollectionView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        agreementLabel.translatesAutoresizingMaskIntoConstraints = false
        userAgreementButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coinCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            coinCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            coinCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            coinCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 205),

            paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            paymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            agreementLabel.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 16),
            agreementLabel.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 16),
            agreementLabel.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: -16),

            userAgreementButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor),
            userAgreementButton.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 16),

            payButton.topAnchor.constraint(equalTo: userAgreementButton.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: -12),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc
    private func userAgreementButtonTapped() {
        let webViewViewController = UserAgreement()
        let webViewPresenter = UserAgreementPresenter()
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.modalPresentationStyle = .fullScreen
        hideLoading()
        self.navigationController?.pushViewController(webViewViewController, animated: true)
    }
}

// MARK: - CollectionViewDataSource
extension PayChoosingController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        coins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PayCell.identifier, for: indexPath) as? PayCell else {
            return UICollectionViewCell()
        }
        cell.setupCell(with: coins[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 168, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}
    
extension PayChoosingController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? PayCell {
            cell.select()
        }
        coinSelected = coins[indexPath.item]
        payButton.isEnabled = true
        payButton.backgroundColor = .segmentActive
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? PayCell {
            cell.deselect()
        }
    }
}

// MARK: - Extension
extension PayChoosingController: PayChoosingProtocol {
    func showLoading() {
        ProgressHUD.animate()
    }

    func hideLoading() {
        ProgressHUD.dismiss()
    }

    func payUpdate(with coins: [Coin]) {
        DispatchQueue.main.async {
            self.coins = coins
            self.coinCollectionView.reloadData()
        }
    }
}
