//
//  NftCellModel.swift
//  FakeNFT
//
//  Created by Irina Gubina on 13.10.2025.
//
import Foundation

struct NftCellModel {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let price: Int
    var isFavorite: Bool
    var isInCart: Bool
    
    init(id: String, name: String, images: String, rating: Int, price: Int, isFavorite: Bool, isInCart: Bool) {
        self.id = id
        self.name = name
        self.images = [images]
        self.rating = rating
        self.price = price
        self.isFavorite = isFavorite
        self.isInCart = isInCart
    }
}
