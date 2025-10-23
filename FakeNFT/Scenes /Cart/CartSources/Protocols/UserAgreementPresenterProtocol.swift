//
//  UserAgreementPresenterProtocol.swift
//  FakeNFT
//
//  Created by R Kolos on 14/10/25.
//

import Foundation

protocol UserAgreementPresenterProtocol {
    var view: UserAgreementViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)

}
