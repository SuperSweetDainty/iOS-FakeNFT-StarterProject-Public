//
//  ResponseOrder.swift
//  FakeNFT
//
//  Created by R Kolos on 12/10/25.
//

import Foundation

struct ResponseOrder: Decodable {
    let nfts: [String]
    let id: String
}
