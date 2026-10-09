import SwiftUI
import SwiftData

struct BrandView: View {
    var brandName: String
    @Query private var cards: [GiftCard]

    init(brandName: String) {
        self.brandName = brandName
        _cards = Query(filter: #Predicate<GiftCard> { $0.retailer == brandName && !$0.isDeleted })
    }

    var body: some View {
        let total = cards.reduce(Decimal(0)) { $0 + $1.balance }
        Text("\(brandName) Giftcards")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
        Text("Number of Cards: \(cards.count)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Total Balance: \(total.formatted(.currency(code: "USD")))")
            .font(.title)
            .multilineTextAlignment(.center)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(cards) { card in
                    HStack{
                        Spacer()
                        NavigationLink(destination:CardView(card: card)){
                            Text("Card ending in \(card.last4)  \(card.balance.formatted(.currency(code: "USD")))")
                        }.buttonStyle(brandScrollButtonStyle())
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    BrandView(brandName: "Sample")
}
