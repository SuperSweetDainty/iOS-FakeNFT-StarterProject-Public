//
//  NetworkModels.swift
//  FakeNFT
//
//  Created by Irina Gubina on 20.10.2025.
//
import Foundation

struct NFTNetworkModel: Decodable {
    let createdAt: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let id: String
}
