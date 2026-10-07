import SwiftUI

struct BrandView: View {
    var brand: Brand
    var body: some View {
        let cards = brand.cards
        Text("\(brand.name) Giftcards")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
        Text("Number of Cards: \(cards.count)")
            .font(.title)
            .multilineTextAlignment(.center)
        Text("Total Balance: $\(brand.total.formatted())")
            .font(.title)
            .multilineTextAlignment(.center)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(cards, id: \.last4) { card in
                    HStack{
                        Spacer()
                        NavigationLink(destination:CardAddView()){
                            Text(card.last4)
                        }.buttonStyle(brandScrollButtonStyle())
                        Spacer()
                    }
                }
            }
        }
        VStack{
            Text("Hi")
        }
    }
}

#Preview {
    BrandView(brand: Brand(cards: [], name: "Sample"))
}
