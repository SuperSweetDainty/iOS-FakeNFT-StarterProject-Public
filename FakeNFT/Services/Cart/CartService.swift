//
//  CartService.swift
//  FakeNFT
//
//  Created by Irina Gubina on 24.10.2025.
//

import Foundation

protocol CartServiceProtocol: AnyObject {
    func addToCart(nftId: String)
    func removeFromCart(nftId: String)
    func isInCart(nftId: String) -> Bool
    func getCartItems() -> [String]
    func clearCart()
}

final class CartService: CartServiceProtocol {
    static let shared = CartService()
    private let cartKey = "cart_items"
    
    private var cartItems: Set<String> {
        get { Set(UserDefaults.standard.array(forKey: cartKey) as? [String] ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: cartKey) }
    }
    
    func addToCart(nftId: String) {
        cartItems.insert(nftId)
        print("Added to cart: \(nftId)")
    }
    
    func removeFromCart(nftId: String) {
        cartItems.remove(nftId)
        print("Removed from cart: \(nftId)")
        
        NotificationCenter.default.post(
            name: .nftCartStateChanged,
            object: nil,
            userInfo: ["nftId": nftId, "isInCart": false]
        )
    }
    
    func isInCart(nftId: String) -> Bool {
        cartItems.contains(nftId)
    }
    
    func getCartItems() -> [String] {
        Array(cartItems)
    }
    
    func clearCart() {
        cartItems = []
        
        NotificationCenter.default.post(
            name: .nftCartCleared,
            object: nil
        )
        print("Cart cleared and notification sent")
    }
}
