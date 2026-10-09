import SwiftUI
import SwiftData
import QuickLook

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var historyFileURL: URL?
    @State private var deletedGiftCards: [DeletedGiftCard] = []
    func previewHistory() {
        let records = (try? fetchAllRecords(context: modelContext)) ?? []
        let text = records.map { $0.message }.joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("AllCardsHistory.txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
        historyFileURL = url
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Welcome to your Giftcard Locker. What do you want to do?").font(.largeTitle).bold().padding(50).multilineTextAlignment(.center)
                NavigationLink(destination:CardExplorerView()){
                    Label("View Cards", systemImage: "magnifyingglass")
                }.buttonStyle(homeScreenButtonStyle())
                
                NavigationLink(destination:CardAddView()){
                    Label("Add Cards", systemImage: "plus")
                }.buttonStyle(homeScreenButtonStyle())
            }
            .toolbar{
                Button(action: {
                    previewHistory()
                }) {
                    Label("All Card History", systemImage: "clock")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .tint(.blue)
                .quickLookPreview($historyFileURL)
            }
        }
        .onAppear {
            deletedGiftCards = (try? fetchAllDeletedCards(context: modelContext)) ?? []
            autodeleteDeletedGiftCards(deletedCards: deletedGiftCards, context: modelContext)
        }
    }
}

#Preview {
    HomeView()
}
