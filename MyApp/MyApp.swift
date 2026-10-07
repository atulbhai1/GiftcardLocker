import SwiftUI
import SwiftData

@main struct MyApp: App {
    init(){
        //let url = FileManager.default.urls(
        //if no such file exists,
        let content = "My super secret data"
        let data = Data(content.utf8)

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("secureFile.txt")

        do {
            try data.write(to: url, options: .completeFileProtection)
        } catch {
            print("Failed to save encrypted file: \(error)")}
    }
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: GiftCard.self)
    }
}
