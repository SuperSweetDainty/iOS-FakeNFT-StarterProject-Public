//
//  PaymentSuccessfully.swift
//  FakeNFT
//
//  Created by R Kolos on 12/10/25.
//

import UIKit

final class PaymentSuccessfully: UIViewController {
    // MARK: - Properties
    private lazy var imageView = {
        let imageView = UIImageView(image: UIImage(resource: .cartNFT))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var buttonReturn: UIButton = {
        let buttonReturn = UIButton()
        buttonReturn.setTitle("Вернуться в корзину", for: .normal)
        buttonReturn.titleLabel?.font = .bodyBold
        buttonReturn.setTitleColor(.white, for: .normal)
        buttonReturn.backgroundColor = .segmentActive
        buttonReturn.layer.cornerRadius = 16
        buttonReturn.addTarget(self, action: #selector(Self.didTapReturnButton), for: .touchUpInside)
        return buttonReturn
    }()

    private lazy var successPayment = {
        let successPayment = UILabel()
        successPayment.text = "Успех! Оплата прошла,\nпоздравляем с покупкой!"
        successPayment.font = .headline3
        successPayment.numberOfLines = 2
        successPayment.textAlignment = .center
        return successPayment
    }()

    // MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSuccessfullyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Methods
    private func setupSuccessfullyView() {
        view.backgroundColor = .systemBackground
        view.addSubview(buttonReturn)
        view.addSubview(successPayment)
        view.addSubview(imageView)
        
        buttonReturn.translatesAutoresizingMaskIntoConstraints = false
        successPayment.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 278),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            successPayment.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 20),
            successPayment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successPayment.bottomAnchor.constraint(equalTo: buttonReturn.topAnchor, constant: -152),

            buttonReturn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonReturn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonReturn.heightAnchor.constraint(equalToConstant: 60),
            buttonReturn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc
    private func didTapReturnButton() {
        navigationController?.popToRootViewController(animated: true)
    }

}

