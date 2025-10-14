//
//  PayChoosingProtocol.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import Foundation

protocol PayChoosingProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func payUpdate(with coins: [Coin])
}
