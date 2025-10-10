import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let rating: Int
    let images: [URL]
    let price: Double
}
