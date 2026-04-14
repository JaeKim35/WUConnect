//
//  User.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/5/26.
//

import Foundation

//Codable to enable saving and loading
struct User: Codable {
    
    //using var for editable
    var name: String
    let schoolInfo: String
    var major: String
    var secondMajor: String

    
    var personalEmail: String
    var schoolEmail: String
    var phone: String

    var imageName: String
    let qrName: String

    var showPersonalEmail: Bool
    var showSchoolEmail: Bool
    var showPhone: Bool
}
