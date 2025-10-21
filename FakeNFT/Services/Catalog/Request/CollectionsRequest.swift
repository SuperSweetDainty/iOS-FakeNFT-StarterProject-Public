//
//  CollectionsRequest.swift
//  FakeNFT
//
//  Created by Irina Gubina on 21.10.2025.
//

import Foundation

struct CollectionsRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
    
    var dto: Dto?
}

