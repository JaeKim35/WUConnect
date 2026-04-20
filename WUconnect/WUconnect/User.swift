//
//  User.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/5/26.
//

import Foundation

//Codable to enable saving and loading
struct User: Codable {
    
    var username: String
    
    //using var for editable
    var name: String
    var schoolInfo: String
    var major: String
    var secondMajor: String

    
    var personalEmail: String
    var schoolEmail: String
    var phone: String

    var imageName: String
    var qrName: String

    var showPersonalEmail: Bool
    var showSchoolEmail: Bool
    var showPhone: Bool
}
