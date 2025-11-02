//
//  CollectionNetworkModel.swift
//  FakeNFT
//
//  Created by Irina Gubina on 20.10.2025.
//
import Foundation

struct CollectionNetworkModel: Decodable {
    let createdAt: String
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let id: String
    
    var nftCount: Int {
        return nfts.count
    }
}
