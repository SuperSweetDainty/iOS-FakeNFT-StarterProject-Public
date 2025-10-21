//
//  WebViewViewController.swift
//  FakeNFT
//
//  Created by Irina Gubina on 15.10.2025.
//

import UIKit
import WebKit

enum WebViewConstants {
    static let authorURLString = "https://practicum.yandex.ru/"
}

public protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    func setActivityIndicatorAnimating(_ isAnimating: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    // MARK: - Public Properties
    var presenter: WebViewPresenterProtocol?
    
    //MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        setupProgressObservation()
        configureBackButton()
        presenter?.viewDidLoad()
    }
    
    // MARK: - IB Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Public Methods
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func setActivityIndicatorAnimating(_ isAnimating: Bool) {
        if isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Private Methods
    private func setupUI(){
        configureView()
        addSubviews()
        setupConstraints()
        setProgressHidden(true)
        setProgressValue(0.0)
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func addSubviews() {
        [webView, progressView, activityIndicator].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Progress View
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            // Web View
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupPresenter() {
        presenter = WebViewPresenter()
        presenter?.view = self
    }
    
    private func setupProgressObservation() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] _, change in
            guard let self = self,
                  let progress = change.newValue else { return }
            
            self.presenter?.didUpdateProgressValue(progress)
        }
    }
    
    private func configureBackButton() {
        navigationItem.hidesBackButton = true
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "nav_back_button"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self,
                             action: #selector(backButtonTapped),
                             for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        backBarButtonItem.width = 24
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
}
