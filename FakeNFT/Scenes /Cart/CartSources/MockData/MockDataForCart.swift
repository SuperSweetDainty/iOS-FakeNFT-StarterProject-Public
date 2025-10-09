//
//  MockDataForCart.swift
//  FakeNFT
//
//  Created by R Kolos on 6/10/25.
//

import Foundation

class MockDataForCart: PresenterCartProtocol {
    // MARK: - Properties
    weak var layoutData: UpdateCartProtocol?

    private let dataNft: [Nft] = {
        func safeUrl(_ string: String) -> URL {
            guard let url = URL(string: string) else {
                fatalError("Invalid URL string: \(string)")
            }
            return url
        }

        return [
            Nft(
                id: "1",
                name: "Emma",
                rating: 1,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/1.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/2.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Brown/Emma/3.png")
                ],
                price: 28.82
            ),
            Nft(
                id: "2",
                name: "Lark",
                rating: 3,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/1.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/2.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Lark/3.png")
                ],
                price: 49.64
            ),
            Nft(
                id: "3",
                name: "Ellsa",
                rating: 5,
                images: [
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/1.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/2.png"),
                    safeUrl("https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/3.png")
                ],
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
