import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    private let url: URL
    
    // MARK: - UI Elements
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadURL()
    }
    
    // MARK: - Navigation Bar Setup
    
    private func setupNavigationBar() {
        // Настройка navigation bar
        navigationItem.title = "Веб-страница"
        
        // Кнопка закрытия слева (стандартный паттерн для модальных экранов)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "1A1B22")
        
        // Или используем иконку "close" если она есть
        if let closeImage = UIImage(named: "close") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: closeImage,
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "1A1B22")
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        [webView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // WebView - занимает весь экран под navigation bar
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить страницу",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
