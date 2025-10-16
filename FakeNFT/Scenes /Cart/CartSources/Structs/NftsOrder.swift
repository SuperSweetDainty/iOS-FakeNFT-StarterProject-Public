//
//  NftsOrder.swift
//  FakeNFT
//
//  Created by R Kolos on 12/10/25.
//

import Foundation

struct NftsOrder: Dto {
    let nfts: String

    func asDictionary() -> [String: String] {
        ["nfts": nfts]
    }
}
