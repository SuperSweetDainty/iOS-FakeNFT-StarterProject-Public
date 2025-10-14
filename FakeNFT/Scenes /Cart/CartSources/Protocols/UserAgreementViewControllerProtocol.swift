//
//  UserAgreementViewControllerProtocol.swift
//  FakeNFT
//
//  Created by R Kolos on 14/10/25.
//

import Foundation

protocol UserAgreementViewControllerProtocol: AnyObject {
    var presenter: UserAgreementPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
