//
//  GiftCard.swift
//  MyApp
//
//  Created by Atul Nitin on 10/3/26.
//

import SwiftData
import CryptoKit
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit


@Model
final class GiftCard{
    var retailer: String
    var balance: Decimal
    var last4: String
    var purchasedFrom: String = ""
    var numberCiphertext: Data
    var pinCipherText: Data
    
    init(retailer: String, number: String, balance: Decimal, pin: String, purchasedFrom: String) throws {
        self.retailer = retailer
        self.balance = balance
        self.last4 = String(number.suffix(4))
        let key = try loadOrCreateKey()
        self.numberCiphertext = try AES.GCM.seal(Data(number.utf8), using: key).combined!
        self.pinCipherText = try AES.GCM.seal(Data(pin.utf8), using:key).combined!
        self.purchasedFrom = purchasedFrom
    }
    func revealNumber() throws -> String {
        let key = try loadOrCreateKey()
        let box = try AES.GCM.SealedBox(combined: numberCiphertext)
        return String(decoding: try AES.GCM.open(box, using: key), as: UTF8.self)
    }
    
    func revealPin() throws -> String{
        let key = try loadOrCreateKey()
        let box = try AES.GCM.SealedBox(combined: pinCipherText)
        return String(decoding: try AES.GCM.open(box, using:key), as: UTF8.self)
    }
}

func fetchAllGiftCards(context: ModelContext) throws -> [GiftCard] {
    let descriptor = FetchDescriptor<GiftCard>()
    return try context.fetch(descriptor)
}

func loadOrCreateKey() throws -> SymmetricKey {
    let account = "giftcard-store-key"
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecReturnData as String: true
    ]
    var item: CFTypeRef?
    if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
       let data = item as? Data {
        return SymmetricKey(data: data)
    }
    let key = SymmetricKey(size: .bits256)
    let data = key.withUnsafeBytes { Data($0) }
    let add: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    guard SecItemAdd(add as CFDictionary, nil) == errSecSuccess else {
        throw NSError(domain: "Keychain", code: 1)
    }
    return key
}

class Brand{
    var cards: [GiftCard]
    var name: String
    var total: Decimal
    init(cards: [GiftCard], name: String){
        self.name = name
        self.cards = cards
        self.total = 0.00
        for card in cards {
            total += card.balance
        }
    }
    
    func add(card: GiftCard){
        self.cards.append(card)
        self.total += card.balance
    }
}

func BrandMaker(cards: [GiftCard]) throws -> [Brand]{
    //Given giftcards list, return brands!!!
    
    var brands = Array<Brand>()
    
    for card in cards{
        var caughtHim = false
        let cardbrand = card.retailer
        for brand in brands {
            if brand.name == cardbrand{
                brand.add(card: card)
                caughtHim = true
                break
            }
        }
        //The above did for if brand was in the list, if not in list, need NEW brand
        if !caughtHim{
            let newBrand = Brand(cards: [card], name: card.retailer)
            brands.append(newBrand)
        }
        //Now have dealt with all, loop again!!!
    }
    return brands
}

func OriginMaker(cards: [GiftCard]) throws -> [String]{
    //Given giftcards list, return purchasedFrom
    
    var origins = Array<String>()
    
    for card in cards{
        var caughtHim = false
        let cardfrom = card.purchasedFrom
        for origin in origins {
            if origin == cardfrom{
                //That origin is already there!!!!
                caughtHim = true
                break
            }
        }
        //The above did for if origin was in the list, if not in list, need NEW origin
        if !caughtHim{
            let newOrigin = card.purchasedFrom
            origins.append(newOrigin)
        }
        //Now have dealt with all, loop again!!!
    }
    return origins
}



func barcodeMaker(cardNumber: String) -> UIImage {
    let inputMessage = Data(cardNumber.utf8)
    let barcodeGenerator = CIFilter.code128BarcodeGenerator()
    barcodeGenerator.message = inputMessage
    guard let outputImage = barcodeGenerator.outputImage else {
        return UIImage()
    }
    // Scale up from the generator's 1pt-per-module output so bars aren't razor-thin,
    // then rasterize to a CGImage since UIImage(ciImage:) often fails to render in SwiftUI.
    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 3, y: 3))
    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
        return UIImage()
    }
    return UIImage(cgImage: cgImage)
}
