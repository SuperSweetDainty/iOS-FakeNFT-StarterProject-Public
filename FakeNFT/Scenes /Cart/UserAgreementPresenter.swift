//
//  UserAgreementPresenter.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import Foundation

final class UserAgreementPresenter: UserAgreementPresenterProtocol {

    weak var view: UserAgreementViewControllerProtocol?

    func viewDidLoad() {
        guard let url = URL(string: RequestConstants.userAgreementURL) else {
            return
        }
        
        let request = URLRequest(url: url)

        didUpdateProgressValue(0)

        view?.load(request: request)
    }

    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

}
