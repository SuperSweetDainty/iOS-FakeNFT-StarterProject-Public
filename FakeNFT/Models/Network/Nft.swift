import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let price: Double
    let rating: Int
    let images: [URL]
    let author: String?
    let description: String?
    
    init(id: String, name: String, price: Double, rating: Int, images: [URL], author: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.rating = rating
        self.images = images
        self.author = author
        self.description = description
    }
}
