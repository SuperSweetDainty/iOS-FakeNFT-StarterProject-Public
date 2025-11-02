//
//  CollectionDetailRequest.swift
//  FakeNFT
//
//  Created by Irina Gubina on 21.10.2025.
//

import Foundation

struct CollectionDetailRequest: NetworkRequest {
    let collectionId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(collectionId)")
    }
    
    var dto: Dto?
}
