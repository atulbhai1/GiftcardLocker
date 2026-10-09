//
//  CardView.swift
//  MyApp
//
//  Created by Atul Nitin on 10/7/26.
//

import SwiftUI
import SwiftData

struct CardView: View {
    @Bindable var card: GiftCard
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showModifyAlert = false
    @State private var showEnterNewBalanceAlert = false
    @State private var showAmountSpentAlert = false
    @State private var showDeleteAlert = false
    @State private var amountSpent: Decimal = 0.0
    var body: some View {
        Text("Card Ending with \(card.last4)")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
        Text("Retailer: \(card.retailer)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Purchased From: \(card.purchasedFrom)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Balance: \(card.balance.formatted(.currency(code: "USD")))")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Card Number: \((try? card.revealNumber()) ?? "Unavailable")")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Card Pin: \((try? card.revealPin()) ?? "Unavailable")")
            .font(.title)
            .multilineTextAlignment(.center)
        if let number = try? card.revealNumber() {
            Image(uiImage: barcodeMaker(cardNumber: number))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        Button("Change Balance", systemImage: "square.and.pencil"){
            showModifyAlert = true
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .alert("Modify Balance", isPresented: $showModifyAlert){
                Button("Enter New Balance", role: .destructive){
                    showEnterNewBalanceAlert = true
                }
                Button("Enter Amount Spent", role: .destructive){
                    showAmountSpentAlert = true
                }
                Button("Cancel", role: .cancel){}

            } message: {
                Text("How do you want to modify the balance?")

            } .alert("New Balance Entry", isPresented: $showEnterNewBalanceAlert){
                TextField("0.00", value: $card.balance, format: .number)
                    .keyboardType(.numberPad)
            } message: {
                Text("Enter New Balance")

            } .alert("Amount Spent Entry", isPresented: $showAmountSpentAlert){
                TextField("0.00", value: $amountSpent, format: .number)
                    .keyboardType(.numberPad)
                Button("Ok"){
                    card.balance = card.balance - amountSpent
                }
            } message: {
                Text("Enter Amount Spent")
            }


        Button("Delete", systemImage: "trash"){
            showDeleteAlert = true
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .alert("Delete Confirmation", isPresented: $showDeleteAlert){
                Button("Delete", role: .destructive){
                    modelContext.delete(card)
                    dismiss()
                }
                Button("Cancel", role: .cancel){}

            } message: {
                Text("Are you sure you want to delete card ending in \(card.last4)?")
            }
    }
}

#Preview {
    if let card = try? GiftCard(retailer: "Starbucks", number: "1234567890123456", balance: 25.00, pin: "1234", purchasedFrom: "Starbucks") {
        CardView(card: card)
    }
}
