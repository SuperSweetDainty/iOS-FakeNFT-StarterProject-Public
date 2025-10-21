//
//  CatalogCollectionNft.swift
//  FakeNFT
//
//  Created by Irina Gubina on 07.10.2025.
//

import Foundation

struct CatalogCollectionNft {
    let id: String
    let name: String
    let nftCount: Int
    let imageURL: String?
    let nftIds: [String]
    let description: String
    let author: String
    
    //TODO: - Для моков
    init(id: String, name: String, nftCount: Int, imageURL: String? = nil, nftIds: [String], description: String = "", author: String = "") {
        self.id = id
        self.name = name
        self.nftCount = nftCount
        self.imageURL = imageURL
        self.nftIds = nftIds
        self.description = description
        self.author = author
    }
}
