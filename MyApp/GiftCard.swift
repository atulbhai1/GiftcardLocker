//
//  GiftCard.swift
//  MyApp
//
//  Created by Atul Nitin on 10/3/26.
//

import SwiftData
import CryptoKit
import Foundation

@Model
final class GiftCard{
    var retailer: String
    var balance: Decimal
    var last4: String
    var numberCiphertext: Data
    var pinCipherText: Data
    init(retailer: String, number: String, balance: Decimal, pin: String) throws {
        self.retailer = retailer
        self.balance = balance
        self.last4 = String(number.suffix(4))
        let key = try loadOrCreateKey()
        self.numberCiphertext = try AES.GCM.seal(Data(number.utf8), using: key).combined!
        self.pinCipherText = try AES.GCM.seal(Data(pin.utf8), using:key).combined!
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
