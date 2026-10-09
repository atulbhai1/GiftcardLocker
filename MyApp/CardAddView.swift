//
//  CardAddView.swift
//  MyApp
//
//  Created by Atul Nitin on 10/4/26.
//

import SwiftUI
import SwiftData

struct CardAddView: View{
    //View to add a gift card
    @State private var balance: Decimal = 10.00
    @State private var cardNumber: String = ""
    @State private var cardPin: String = ""
    @State private var retailer: String = "Other"
    @State private var customRetailer: String = ""
    @State private var purchasedFrom: String = "Other"
    @State private var otherPurchasedFrom: String = ""
    @State private var notSaved = false
    @State private var showAlert = false
    @State private var goToConfirmation = false
    @State private var errorMessage = ""
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var body : some View{
        let ExistingCards = (try? fetchAllGiftCards(context: modelContext)) ?? Array<GiftCard>()
        let Brands = (try? BrandMaker(cards: ExistingCards)) ?? Array<Brand>()
        let Origins = (try? OriginMaker(cards: ExistingCards)) ?? Array<String>()
        VStack{
            
            Text("Add A Gift Card").font(.largeTitle).bold().padding(20)
            Spacer()
            Form{
                //Balance Entry
                HStack{
                    Spacer()
                    Text("Balance: ").font(.title).bold()
                    TextField("0.00", value: $balance, format: .number)
                        .keyboardType(.numberPad).font(.title)
                        .padding(8)
                        .frame(width: 150)
                        .multilineTextAlignment(.center)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                //Spacer()
                HStack{
                    Spacer()
                    Text("Number: ").font(.title).bold()
                    TextField("1234567890", text: $cardNumber)
                        .font(.title)
                        .padding(8)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Text("Pin: ").font(.title).bold()
                    TextField("1234", text: $cardPin)
                        .font(.title)
                        .padding(8)
                        .frame(width: 150)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Text("Retailer: ").font(.title).bold()
                    Menu {
                        ForEach(Brands, id: \.name) { brand in
                            Button(brand.name) { retailer = brand.name }
                        }
                        Button("Other") { retailer = "Other" }
                    } label: {
                        Text(retailer).font(.title).bold()
                    }
                    Spacer()
                }
                
                if "Other" == retailer{
                    HStack{
                        Spacer()
                        Text("Other Retailer: ").font(.title).bold()
                        TextField("Retailer", text: $customRetailer)
                            .font(.title)
                            .padding(8)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                HStack{
                    Spacer()
                    Text("Purchased From: ").font(.title).bold()
                    Menu {
                        ForEach(Origins, id: \.self) { origin in
                            Button(origin) { purchasedFrom = origin }
                        }
                        Button("Other") { purchasedFrom = "Other" }
                    } label: {
                        Text(purchasedFrom).font(.title).bold()
                    }
                    Spacer()
                }
                
                if "Other" == purchasedFrom{
                    HStack{
                        Spacer()
                        Text("Other Card Origin: ").font(.title).bold()
                        TextField("Origin", text: $otherPurchasedFrom)
                            .font(.title)
                            .padding(8)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                HStack{
                    Spacer()
                    Button("Add"){
                        notSaved = false
                        do {
                            try addCard(context: modelContext, cardBalance: balance, cardNumber: cardNumber, cardPin: cardPin, retailer: retailer, otherRetailer: customRetailer, purchasedFrom: purchasedFrom, customPurchasedFrom: otherPurchasedFrom)
                        }
                        catch let error as CocoaError where error.code == .formatting {
                            notSaved = true
                            errorMessage = "Ensure you entered input for Retailer, Card Origin, and the Card Number!!!"
                        }
                        catch {
                            errorMessage = "Something went wrong while saving your card. Please try again."
                            notSaved = true
                        }
                        if notSaved{
                            showAlert = true
                        }
                        else{//Change screen
                            goToConfirmation = true
                        }
                    }.buttonStyle(dismissButtonStyle()).multilineTextAlignment(.center)
                    Spacer()
                }}
        }
        .sheet(isPresented: $goToConfirmation, onDismiss: { dismiss() }) {
            CardAddedConfirmationView()
        }
        .alert("Couldn't Save Card", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    CardAddView()
}

func addCard(context: ModelContext, cardBalance: Decimal, cardNumber: String, cardPin: String, retailer: String, otherRetailer: String, purchasedFrom: String, customPurchasedFrom: String) throws {
    let finalRetailer = (retailer != "Other") ? retailer : otherRetailer
    let finalPurchasedFrom = (purchasedFrom != "Other") ? purchasedFrom : customPurchasedFrom
    if (finalRetailer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || finalPurchasedFrom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
        throw CocoaError(.formatting)
    }
    let card = try GiftCard(retailer: finalRetailer, number: cardNumber, balance: cardBalance, pin: cardPin, purchasedFrom: finalPurchasedFrom)
    context.insert(card)
}
