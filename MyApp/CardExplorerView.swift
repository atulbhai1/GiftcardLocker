import SwiftUI
import _SwiftData_SwiftUI

struct CardExplorerView: View {
    @Query(sort: \GiftCard.retailer) private var cards: [GiftCard]
    var body: some View {
        let brands = (try? BrandMaker(cards: cards)) ?? []

        Text("hi").navigationTitle("Card Explorer")
    }
}

#Preview {
    CardExplorerView()
}
