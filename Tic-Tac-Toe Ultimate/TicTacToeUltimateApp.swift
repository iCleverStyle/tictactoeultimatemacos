import SwiftUI

@main
struct TicTacToeUltimateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            GameStartView()
        }
    }
} 