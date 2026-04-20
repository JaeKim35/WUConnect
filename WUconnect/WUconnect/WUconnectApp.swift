//
//  WUconnectApp.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 3/29/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct WUconnectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appState = AppState()
    @StateObject private var contactsStore = ContactsStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if appState.currentUser != nil {
                    ProfileView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(appState)
            .environmentObject(contactsStore)
        }
    }
    
}
