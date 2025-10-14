//
//  PayRequest.swift
//  FakeNFT
//
//  Created by R Kolos on 10/10/25.
//

import Foundation

struct PayRequest: NetworkRequest {
    var dto: (any Dto)?
    var httpMethod: HttpMethod = .get
    var endpoint: URL? {
        URL(string: RequestConstants.paymentURL)
    } 
}
