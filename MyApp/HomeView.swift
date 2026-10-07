import SwiftUI

struct HomeView: View {
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
        }}
}

#Preview {
    HomeView()
}
