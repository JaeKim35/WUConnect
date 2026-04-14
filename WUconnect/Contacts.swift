//
//  Contacts.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/5/26.
//

import Foundation

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let schoolInfo: String
    let major: String
    let personalEmail: String
    let schoolEmail: String
    let phone: String
    let imageName: String
    let qrName: String
}

struct ContactGroup: Identifiable {
    let id = UUID()
    var name: String
    var contacts: [Contact]
}
