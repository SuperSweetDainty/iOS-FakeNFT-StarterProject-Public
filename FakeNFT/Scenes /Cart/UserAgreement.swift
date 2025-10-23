//
//  UserAgreement.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import UIKit
@preconcurrency import WebKit

final class UserAgreement: UIViewController, UserAgreementViewControllerProtocol {
    // MARK: - Properties
    var presenter: UserAgreementPresenterProtocol?
    private var progressObservation: NSKeyValueObservation?
    
    private lazy var userAgreementWebView: WKWebView = {
        let userAgreementWebView = WKWebView()
        view.addSubview(userAgreementWebView)
        return userAgreementWebView
    }()
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .segmentActive
        progressView.progressViewStyle = .default
        view.addSubview(progressView)
        return progressView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Пользовательское соглашение"
        setupView()
        presenter?.viewDidLoad()
        observeProgress()
    }

    // MARK: - Methods
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        userAgreementWebView.load(request)
    }

    private func setupView() {
        self.view.backgroundColor = .systemBackground

        userAgreementWebView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            userAgreementWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userAgreementWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userAgreementWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userAgreementWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func observeProgress() {
        progressObservation = userAgreementWebView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let self else { return }
            self.presenter?.didUpdateProgressValue(self.userAgreementWebView.estimatedProgress)
        }
    }
}

