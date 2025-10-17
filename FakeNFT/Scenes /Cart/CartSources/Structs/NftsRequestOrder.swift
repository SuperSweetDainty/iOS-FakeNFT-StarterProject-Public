//
//  NftsRequestOrder.swift
//  FakeNFT
//
//  Created by R Kolos on 12/10/25.
//

import Foundation

struct NftsRequestOrder: NetworkRequest {
    var dto: (any Dto)?
    
    var endpoint: URL? {
        URL(string: RequestConstants.orderURL)
    }

    var httpMethod: HttpMethod = .put
}
