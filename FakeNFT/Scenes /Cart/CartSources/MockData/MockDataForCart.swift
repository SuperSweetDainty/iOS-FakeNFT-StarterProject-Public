//
//  MockDataForCart.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import UIKit

class MockDataForCart: PresenterCartProtocol {
    // MARK: - Properties
    weak var layoutData: UpdateCartProtocol?
    
    private let dataNft: [Nft] = {
        func safeUrl(_ string: String) -> (url: URL?, localImage: UIImage?) {
            if let url = URL(string: string) {
                return (url, nil)
            } else {
                assertionFailure("Invalid URL string: \(string)")
                return (nil, UIImage(named: "placeholder"))
            }
        }
        
        return [
            Nft(
                id: "1",
                name: "Emma",
                rating: 1,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/1.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/2.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/3.png").url
                ].compactMap { $0 },
                price: 28.82
            ),
            Nft(
                id: "2",
                name: "Lark",
                rating: 3,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/1.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/2.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/3.png").url
                ].compactMap { $0 },
                price: 49.64
            ),
            Nft(
                id: "3",
                name: "Ellsa",
                rating: 5,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/1.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/2.png").url,
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/3.png").url
                ].compactMap { $0 },
                price: 39.37
            ),
        ]
    }()

    init(view: UpdateCartProtocol, networkService: NetworkClient = DefaultNetworkClient()) {
        self.layoutData = view
    }
    
    func viewDidLoad() {
        extractMock()
    }
    
    private func extractMock() {
        layoutData?.nftUpdate(with: dataNft)
    }
}
