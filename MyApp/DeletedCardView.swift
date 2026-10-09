//
//  DeletedCardView.swift
//  MyApp
//
//  Created by Atul Nitin on 10/9/26.
//

import SwiftUI
import SwiftData

struct DeletedCardView: View {
    @Bindable var deletedCard: DeletedGiftCard
    @State private var showDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var body: some View{
        let card = deletedCard.giftCard
        Text("Deleted Card Ending with \(card.last4)")
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
        }
        Text("Deleted On: \(deletedCard.deletionTime.formatted(date: .numeric, time: .complete))")
            .font(.title)
            .multilineTextAlignment(.center)
        
        Text("Auto-Deletes Forever On: \(Calendar.current.date(byAdding: .day, value: 60, to: deletedCard.deletionTime)?.formatted(date: .numeric, time: .complete) ?? "Error")")
            .font(.title)
            .multilineTextAlignment(.center)
        
        Button("Restore", systemImage: "trash.slash"){
            card.add_record(record: Record(type: Record.RESTORED, beforeBalance: card.balance, afterBalance: card.balance, cardLast4: card.last4))
            card.isDeleted = false
            modelContext.delete(deletedCard)
            dismiss()
        }.buttonStyle(modifyOrDeleteButtonStyle())
            
        
        Button("Delete Forever", systemImage: "trash"){
            showDeleteAlert = true
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .alert("Delete Confirmation", isPresented: $showDeleteAlert){
                Button("Delete Forever", role: .destructive){
                    let tempRecord = Record(type: Record.FDELETED, beforeBalance: card.balance, afterBalance: 0, cardLast4: card.last4)
                    modelContext.delete(deletedCard)
                    modelContext.delete(card)
                    modelContext.insert(tempRecord)
                    dismiss()
                }
                Button("Cancel", role: .cancel){}

            } message: {
                Text("Are you sure you want to delete card ending in \(card.last4)? This cannot be undone.")
            }

    }
        
    }
    
    

#Preview {
    if let card = try? GiftCard(retailer: "Starbucks", number: "1234567890123456", balance: 25.00, pin: "1234", purchasedFrom: "Starbucks") {
        
        DeletedCardView(deletedCard: DeletedGiftCard(card: card))
    }
}
