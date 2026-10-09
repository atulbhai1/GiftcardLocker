//
//  DeletedCardExplorer.swift
//  MyApp
//
//  Created by Atul Nitin on 10/9/26.
//

import SwiftUI
import _SwiftData_SwiftUI

struct DeletedCardExplorer: View {
    @Environment(\.modelContext) private var modelContext
    @State private var deletedGiftCards: [DeletedGiftCard] = []
    var body: some View {
        Text("Select Deleted Card:")
            .font(.largeTitle).bold().multilineTextAlignment(.center).padding(20)
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(deletedGiftCards, id: \.deletionTime) { deletedCard in
                    HStack{
                        Spacer()
                        NavigationLink(destination: DeletedCardView(deletedCard: deletedCard)){
                            Text("Card Ending in \(deletedCard.giftCard.last4)")
                        }.buttonStyle(brandScrollButtonStyle())
                        Spacer()
                    }
                }
            }
        }.onAppear {
            deletedGiftCards = (try? fetchAllDeletedCards(context: modelContext)) ?? []
        }
        //Spacer()
        
    }
        
        
}

#Preview {
    DeletedCardExplorer()
}
