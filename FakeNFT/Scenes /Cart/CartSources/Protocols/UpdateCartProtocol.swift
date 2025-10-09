//
//  UpdateCartProtocol.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import Foundation

protocol UpdateCartProtocol: AnyObject {
    func nftUpdate(with nfts: [Nft])
}
