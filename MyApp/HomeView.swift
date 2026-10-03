import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView{
            VStack {
                Text("Welcome to Your Giftcard Locker. What do you want to do?").font(.largeTitle).bold().padding(50).multilineTextAlignment(.center)
                NavigationLink(destination:CardExplorerView()){
                    Text("View Cards")
                }.buttonStyle(homeScreenButtonStyle())
                
                NavigationLink(destination:CardExplorerView()){
                    Text("Add Cards")
                }.buttonStyle(homeScreenButtonStyle())
                
            }
        }}
}

#Preview {
    HomeView()
}
