//
//  RequestForCart.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import Foundation

struct RequestForCart: NetworkRequest {
    var dto: (any Dto)?
    
    var endpoint: URL? {
        URL(string: RequestConstants.orderURL)
    }
    
    var httpMethod: HttpMethod = .get
}
