//
//  SortOption.swift
//  FakeNFT
//
//  Created by Irina Gubina on 08.10.2025.
//

import Foundation

enum SortOption: String, CaseIterable {
    case byName = "По названию"
    case byNftCount = "По колличеству NFT"
    
    func sortCollections(_ collections: [CatalogCollectionNft]) -> [CatalogCollectionNft] {
        switch self {
        case .byName:
            return collections.sorted { $0.name < $1.name }
        case .byNftCount:
            return collections.sorted {$0.nftCount > $1.nftCount}
        }
    }
    
    static var allCases: [SortOption] {
        return [.byName, .byNftCount]
    }
}
