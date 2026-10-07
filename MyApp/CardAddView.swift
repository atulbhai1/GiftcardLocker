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
    @State private var showAlert = false
    @Environment(\.modelContext) private var modelContext
    var body : some View{
        let ExistingCards = (try? fetchAllGiftCards(context: modelContext)) ?? Array<GiftCard>()
        let Brands = (try? BrandMaker(cards: ExistingCards)) ?? Array<Brand>()
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
                
                Spacer()
                
                Button("Add"){
                    try? addCard(context: modelContext, cardBalance: balance, cardNumber: cardNumber, cardPin: cardPin, retailer: retailer, otherRetailer: customRetailer) ?? showAlert = false
                }
                
            }
        }
    }
}

#Preview {
    CardAddView()
}

func addCard(context: ModelContext, cardBalance: Decimal, cardNumber: String, cardPin: String, retailer: String, otherRetailer: String) throws {
    let finalRetailer = (retailer != "Other") ? retailer : otherRetailer
    let card = try GiftCard(retailer: finalRetailer, number: cardNumber, balance: cardBalance, pin: cardPin)
    context.insert(card)
}
