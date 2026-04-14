//
//  WUconnectApp.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 3/29/26.
//

import SwiftUI

@main

struct WUconnectApp: App {
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
