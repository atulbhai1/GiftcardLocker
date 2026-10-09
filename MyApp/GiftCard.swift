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
import SwiftUI


@Model
final class GiftCard{
    var retailer: String
    var balance: Decimal
    var last4: String
    var purchasedFrom: String = ""
    var numberCiphertext: Data
    var pinCipherText: Data
    var history: [Record] = Array<Record>()
    var isDeleted: Bool = false
    
    
    init(retailer: String, number: String, balance: Decimal, pin: String, purchasedFrom: String) throws {
        self.retailer = retailer
        self.balance = balance
        self.last4 = String(number.suffix(4))
        let key = try loadOrCreateKey()
        self.numberCiphertext = try AES.GCM.seal(Data(number.utf8), using: key).combined!
        self.pinCipherText = try AES.GCM.seal(Data(pin.utf8), using:key).combined!
        self.purchasedFrom = purchasedFrom
        self.history = Array<Record>([Record(type: Record.CREATED, beforeBalance: 0.00, afterBalance: balance, cardLast4: String(number.suffix(4)))])
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
    
    func add_record(record: Record){
        self.history.append(record)
    }
}

func fetchAllGiftCards(context: ModelContext) throws -> [GiftCard] {
    let descriptor = FetchDescriptor<GiftCard>(predicate: #Predicate { !$0.isDeleted })
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
    return brands.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
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



private let barcodeRenderContext = CIContext()

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
    guard let cgImage = barcodeRenderContext.createCGImage(scaledImage, from: scaledImage.extent) else {
        return UIImage()
    }
    return UIImage(cgImage: cgImage)
}

@Model
final class Record{
    var type: String
    var beforeBalance: Decimal
    var afterBalance: Decimal
    var cardLast4: String
    var time: Date
    var message: String
    static let CREATED = "CREATED"
    static let TRANSACTION = "TRANSACTION"
    static let DELETED = "DELETED"
    static let FDELETED = "FOREVERDELETED"
    static let RESTORED = "RESTORED"
    
    init(type: String, beforeBalance: Decimal, afterBalance: Decimal, cardLast4: String) {
        self.type = type
        self.beforeBalance = beforeBalance
        self.afterBalance = afterBalance
        self.cardLast4 = cardLast4
        self.time = Date()
        let displayTime = Date().formatted(date: .numeric, time: .complete)
        
        if (type == Record.CREATED){
            self.message = "Card ending in \(cardLast4) was created with balance \(afterBalance) at \(displayTime)."
        }
        else if (type == Record.TRANSACTION){
            self.message = "Card ending in \(cardLast4) had its balance updated from \(beforeBalance.formatted(.currency(code: "USD"))) to \(afterBalance.formatted(.currency(code: "USD"))) at \(displayTime)."
        }
        else if (type == Record.DELETED){
            self.message = "Card ending in \(cardLast4) was deleted at \(displayTime)."
        }
        else if (type == Record.FDELETED){
            self.message = "Card ending in \(cardLast4) was forever deleted at \(displayTime)."
        }
        else if(type == Record.RESTORED){
            self.message = "Card ending in \(cardLast4) was restored at \(displayTime)."
        }
        else{
            self.message = "Somthing unexpected was recorded at \(displayTime)."
        }
    }
}

func fetchAllRecords(context: ModelContext) throws -> [Record] {
    let descriptor = FetchDescriptor<Record>(sortBy: [SortDescriptor(\.time, order: .forward)])
    return try context.fetch(descriptor)
}

@Model
final class DeletedGiftCard{
    @Relationship(deleteRule: .nullify) var giftCard: GiftCard
    var deletionTime: Date
    
    init(card: GiftCard) {
        self.giftCard = card
        self.deletionTime = Date()
    }
}

func fetchAllDeletedCards(context: ModelContext) throws -> [DeletedGiftCard] {
    let descriptor = FetchDescriptor<DeletedGiftCard>(sortBy: [SortDescriptor(\.deletionTime, order: .forward)])
    return try context.fetch(descriptor)
}

func autodeleteDeletedGiftCards(deletedCards: [DeletedGiftCard], context: ModelContext){
    let now = Date()
    guard let cutoffDate = Calendar.current.date(byAdding: .day, value: -60, to: now) else { return }
    for deletedCard in deletedCards where deletedCard.deletionTime < cutoffDate {
        context.delete(deletedCard)
        context.delete(deletedCard.giftCard)
    }
}
