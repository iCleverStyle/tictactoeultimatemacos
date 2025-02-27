//
//  AppDelegate.swift
//  Tic-Tac-Toe Ultimate
//
//  Created by Евгений on 27.02.25.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow?
    var appInstance: TicTacToeUltimateApp?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем экземпляр нашего приложения SwiftUI
        let app = TicTacToeUltimateApp()
        self.appInstance = app
        
        // Получаем первое представление
        let contentView = GameStartView()
        
        // Создаем окно
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        self.window = window
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Код для завершения приложения
    }
}
