//
//  Contacts.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/5/26.
//

import Foundation

struct Contact: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let name: String
    let schoolInfo: String
    let major: String
    let personalEmail: String
    let schoolEmail: String
    let phone: String
    let imageName: String
    let qrName: String

    init(
        id: UUID = UUID(),
        username: String = "",
        name: String = "",
        schoolInfo: String = "",
        major: String = "",
        personalEmail: String = "",
        schoolEmail: String = "",
        phone: String = "",
        imageName: String = "",
        qrName: String = ""
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.schoolInfo = schoolInfo
        self.major = major
        self.personalEmail = personalEmail
        self.schoolEmail = schoolEmail
        self.phone = phone
        self.imageName = imageName
        self.qrName = qrName
    }
}


struct ContactGroup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var contacts: [Contact]
    
    init(id: UUID = UUID(), name: String, contacts: [Contact]) {
        self.id = id
        self.name = name
        self.contacts = contacts
    }
}

