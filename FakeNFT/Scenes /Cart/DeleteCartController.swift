//
//  DeleteCartController.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import UIKit

final class DeleteCartController: UIViewController {
    // MARK: -  Properties
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var onDelete: (() -> Void)?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .fakeNft)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.titleLabel?.font = .bodyRegular
        deleteButton.setTitleColor(.redUniversal, for: .normal)
        deleteButton.backgroundColor = .segmentActive
        deleteButton.layer.cornerRadius = 12
        deleteButton.addTarget(self, action: #selector(deleteNFT), for: .touchUpInside)
        return deleteButton
    }()

    private lazy var toReturnButton: UIButton = {
        let toReturnButton = UIButton(type: .system)
        toReturnButton.setTitle("Вернуться", for: .normal)
        toReturnButton.setTitleColor(.white, for: .normal)
        toReturnButton.titleLabel?.font = .bodyRegular
        toReturnButton.backgroundColor = .segmentActive
        toReturnButton.layer.cornerRadius = 12
        toReturnButton.addTarget(self, action: #selector(cancelDeleteNFT), for: .touchUpInside)
        return toReturnButton
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы уверены, что хотите \nудалить объект из корзины?"
        label.font = .caption2
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView()
        setupView()
    }
    
    // MARK: - Methods
    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [deleteButton, toReturnButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually

        let contentStack = UIStackView(arrangedSubviews: [imageView, textLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [contentStack, stack])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            imageView.widthAnchor.constraint(equalToConstant: 108),
            imageView.heightAnchor.constraint(equalToConstant: 108),

            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 127),
            toReturnButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor),
            toReturnButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor),
        ])
    }
    
    func setupImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func blurView() {
        view.backgroundColor = .clear
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }

    @objc private func deleteNFT() {
        dismiss(animated: true) {
            self.onDelete?()
        }
    }

    @objc private func cancelDeleteNFT() {
        dismiss(animated: true)
    }
}
