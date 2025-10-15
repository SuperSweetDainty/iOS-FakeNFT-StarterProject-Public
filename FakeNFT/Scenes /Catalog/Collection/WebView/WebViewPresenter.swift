//
//  WebViewPresenter.swift
//  FakeNFT
//
//  Created by Irina Gubina on 15.10.2025.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ progress: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: WebViewViewControllerProtocol?
    
    // MARK: - Private Properties
    private var currentProgress: Double = 0.0
    
    // MARK: - Public Methods
    func viewDidLoad() {
        // Начальная настройка view
        view?.setProgressHidden(true)
        view?.setProgressValue(0.0)
        view?.setActivityIndicatorAnimating(true)
    }
    
    func didUpdateProgressValue(_ progress: Double) {
        currentProgress = progress
        updateViewForProgress(progress)
    }
    
    // MARK: - Private Methods
    private func updateViewForProgress(_ progress: Double) {
        let progressFloat = Float(progress)
        
        view?.setProgressValue(progressFloat)
        
        // Управляем видимостью прогресс-бара и activityIndicator
        if progress > 0 && progress < 1.0 {
            view?.setProgressHidden(false)
            // Останавливаем activityIndicator когда начинается реальная загрузка
            if progress > 0.1 {
                view?.setActivityIndicatorAnimating(false)
            }
        } else if progress >= 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.view?.setProgressHidden(true)
                self?.view?.setProgressValue(0.0)
                self?.view?.setActivityIndicatorAnimating(false)
            }
        }
    }
}
