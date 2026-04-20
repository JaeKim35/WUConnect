//
//  AppState.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/6/26.
//

import SwiftUI
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var currentUser: User? = nil

    private let userKey = "savedUser"

    init() {
        loadUser()
    }

    //Save user
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
        currentUser = user
    }

    //Load user
    func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }

    
    //Update user
    func updateUser(_ updatedUser: User) {
        currentUser = updatedUser

        if UserDefaults.standard.data(forKey: userKey) != nil {
            if let data = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(data, forKey: userKey)
            }
        }
    }

    
    //Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser = nil
    }
}
