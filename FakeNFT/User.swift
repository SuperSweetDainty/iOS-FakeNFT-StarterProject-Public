import Foundation

struct User: Decodable {
    let id: String
    let name: String
    let description: String
    let avatar: URL?
    let website: URL?
    let nfts: [String] // NFT IDs
    let likes: [String] // NFT IDs
}

struct Profile: Decodable {
    let user: User
}
