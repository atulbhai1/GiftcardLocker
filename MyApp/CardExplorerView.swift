import SwiftUI
import _SwiftData_SwiftUI

struct CardExplorerView: View {
    @Query(filter: #Predicate<GiftCard> { !$0.isDeleted }, sort: \GiftCard.retailer) private var cards: [GiftCard]
    var body: some View {
        let brands = (try? BrandMaker(cards: cards)) ?? []
        Text("Select Card Retailer:")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(brands, id: \.name) { brand in
                    HStack{
                        Spacer()
                        NavigationLink(destination:BrandView(brandName: brand.name)){
                            Text("\(brand.name)  $\(brand.total.formatted())")
                        }.buttonStyle(brandScrollButtonStyle())
                        Spacer()
                    }
                }
            }
        }
        
        //Spacer()
        
    }
}

#Preview {
    CardExplorerView()
}
