//
//  CardView.swift
//  MyApp
//
//  Created by Atul Nitin on 10/7/26.
//

import SwiftUI
import SwiftData
import QuickLook

enum BalanceAlert: Identifiable {
    case modifyChoice
    case newBalance
    case amountSpent

    var id: Self { self }

    var title: String {
        switch self {
        case .modifyChoice: return "Modify Balance"
        case .newBalance: return "New Balance Entry"
        case .amountSpent: return "Amount Spent Entry"
        }
    }
}

struct CardView: View {
    @Bindable var card: GiftCard
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var activeBalanceAlert: BalanceAlert?
    @State private var showDeleteAlert = false
    @State private var amountSpent: Decimal = 0.0
    @State private var balanceBeforeEdit: Decimal = 0.0
    @State private var historyFileURL: URL?
    @State private var revealedNumber: String?
    @State private var revealedPin: String?
    @State private var barcodeImage: UIImage?

    private var isBalanceAlertPresented: Binding<Bool> {
        Binding(
            get: { activeBalanceAlert != nil },
            set: { if !$0 { activeBalanceAlert = nil } }
        )
    }

    func previewHistory() {
        let text = card.history
            .sorted { $0.time < $1.time }
            .map { $0.message }
            .joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Card-\(card.last4)-History.txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        historyFileURL = url
    }
    func refreshRevealedFields() {
        revealedNumber = try? card.revealNumber()
        revealedPin = try? card.revealPin()
        if let revealedNumber {
            barcodeImage = barcodeMaker(cardNumber: revealedNumber)
        }
    }

    var body: some View {
        Text("Card Ending with \(card.last4)")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
            .onAppear(perform: refreshRevealedFields)
        Text("Retailer: \(card.retailer)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Purchased From: \(card.purchasedFrom)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Balance: \(card.balance.formatted(.currency(code: "USD")))")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Card Number: \(revealedNumber ?? "Unavailable")")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Card Pin: \(revealedPin ?? "Unavailable")")
            .font(.title)
            .multilineTextAlignment(.center)
        if let barcodeImage {
            Image(uiImage: barcodeImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        Button("Change Balance", systemImage: "square.and.pencil"){
            activeBalanceAlert = .modifyChoice
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .alert(
                activeBalanceAlert?.title ?? "",
                isPresented: isBalanceAlertPresented,
                presenting: activeBalanceAlert
            ) { alert in
                switch alert {
                case .modifyChoice:
                    Button("Enter New Balance", role: .destructive){
                        balanceBeforeEdit = card.balance
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeBalanceAlert = .newBalance
                        }
                    }
                    Button("Enter Amount Spent", role: .destructive){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeBalanceAlert = .amountSpent
                        }
                    }
                    Button("Cancel", role: .cancel){}
                case .newBalance:
                    TextField("0.00", value: $card.balance, format: .number)
                        .keyboardType(.numberPad)
                    Button("OK"){
                        card.add_record(record: Record(type: Record.TRANSACTION, beforeBalance: balanceBeforeEdit, afterBalance: card.balance, cardLast4: card.last4))
                    }
                case .amountSpent:
                    TextField("0.00", value: $amountSpent, format: .number)
                        .keyboardType(.numberPad)
                    Button("OK"){
                        let before = card.balance
                        card.balance = card.balance - amountSpent
                        card.add_record(record: Record(type: Record.TRANSACTION, beforeBalance: before, afterBalance: card.balance, cardLast4: card.last4))
                    }
                }
            } message: { alert in
                switch alert {
                case .modifyChoice:
                    Text("How do you want to modify the balance?")
                case .newBalance:
                    Text("Enter New Balance")
                case .amountSpent:
                    Text("Enter Amount Spent")
                }
            }


        Button("View History", systemImage: "clock"){
            previewHistory()
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .quickLookPreview($historyFileURL)

        Button("Delete", systemImage: "trash"){
            showDeleteAlert = true
        }.buttonStyle(modifyOrDeleteButtonStyle())
            .alert("Delete Confirmation", isPresented: $showDeleteAlert){
                Button("Delete", role: .destructive){
                    card.add_record(record: Record(type: Record.DELETED, beforeBalance: card.balance, afterBalance: card.balance, cardLast4: card.last4))
                    card.isDeleted = true
                    modelContext.insert(DeletedGiftCard(card: card))
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
