import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let price: Double
    let rating: Int
    let images: [URL]
    let author: String
    let description: String
}
