//
//  ContactsStore.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/13/26.
//

import SwiftUI
import Combine

class ContactsStore: ObservableObject {
    //save automatically when groups change
    @Published var contactGroups: [ContactGroup] {
        didSet {
            saveData()
        }
    }
    @Published var allContacts: [Contact] {
        didSet {
            saveData()
        }
    }
    
    private let groupsKey = "savedContactGroups"
    private let contactsKey = "savedAllContacts"
    
    init() {
        //Try loading saved groups
        if let savedGroupsData = UserDefaults.standard.data(forKey: groupsKey),
           let decodedGroups = try? JSONDecoder().decode([ContactGroup].self, from: savedGroupsData) {
            self.contactGroups = decodedGroups
        } else {
            
            self.contactGroups = []
        }
        
        
        //test loading saved contacts
        if let savedContactsData = UserDefaults.standard.data(forKey: contactsKey),
           let decodedContacts = try? JSONDecoder().decode([Contact].self, from: savedContactsData) {
            self.allContacts = decodedContacts
        } else {
            //Default contacts data if nothing is saved yet
            self.allContacts = []
        }
    }
    
    
    
    //saving both groups and contacts into UserDefaults
    func saveData(){
        if let encodedGroups = try? JSONEncoder().encode(contactGroups) {
            UserDefaults.standard.set(encodedGroups, forKey: groupsKey)
        }
        
        if let encodedContacts = try? JSONEncoder().encode(allContacts) {
            UserDefaults.standard.set(encodedContacts, forKey: contactsKey)
        }
    }
    
    
    //creating new group
    func createGroup(name:String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return
        }
        
        let alreadyExists = contactGroups.contains {
            $0.name.lowercased() == trimmedName.lowercased()
        }
        
        if alreadyExists {
            return
        }
        
        contactGroups.append(
            ContactGroup(
                name: trimmedName,
                contacts: []
            )
        )
    }
    
    
    //renaming groups
    func renameGroup(groupId: UUID, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            return
        }
        
        guard let groupIndex = contactGroups.firstIndex(where: { $0.id == groupId }) else {
            return
        }
        
        let alreadyExists = contactGroups.contains {
            $0.id != groupId && $0.name.lowercased() == trimmedName.lowercased()
        }
        
        if alreadyExists {
            return
        }
        
        contactGroups[groupIndex].name = trimmedName
    }
    
    //delete group
    func deleteGroup(groupId: UUID) {
        contactGroups.removeAll { $0.id == groupId }
    }
    
    
    
    //adding selected contacts into one group
    func addContacts(_ contacts: [Contact], to groupId: UUID){
        guard let groupIndex = contactGroups.firstIndex(where: { $0.id == groupId }) else {
            return
        }
        
        for contact in contacts {
            let alreadyExists = contactGroups[groupIndex].contacts.contains(where: { $0.id == contact.id })
            
            if !alreadyExists {
                contactGroups[groupIndex].contacts.append(contact)
            }
        }
    }
    
    //updating group members, add/remove
    func updateGroupMembers(groupId: UUID, newContacts: [Contact]) {
        guard let groupIndex = contactGroups.firstIndex(where: { $0.id == groupId }) else {
            return
        }
        
        contactGroups[groupIndex].contacts = newContacts
    }
    
    //removing one contact from a group
    func removeContacts(_ contact: Contact, from groupId: UUID) {
        guard let groupIndex = contactGroups.firstIndex(where: { $0.id == groupId }) else {
            return
        }
        
        contactGroups[groupIndex].contacts.removeAll { $0.id == contact.id }
    }
    
    
    //getting a group by id
    func group(for groupId: UUID) -> ContactGroup? {
        contactGroups.first(where: { $0.id == groupId })
    }
    
    //return contacts that are not in the group
    func availableContacts(for groupId: UUID) -> [Contact] {
        guard let group = group(for: groupId) else {
            return allContacts
        }
        
        return allContacts.filter { contact in
            !group.contacts.contains(where: { $0.id == contact.id })
        }
    }
}
    
    
    
//    //testing for resetting data
//    func resetData() {
//        UserDefaults.standard.removeObject(forKey: groupsKey)
//        UserDefaults.standard.removeObject(forKey: contactsKey)
//
//        contactGroups = [
//            ContactGroup(
//                name: "CSE 4308",
//                contacts: [
//                    Contact(
//                        name: "Apple Apple",
//                        schoolInfo: "WashU - Senior",
//                        major: "Computer Science",
//                        personalEmail: "appleapple@gmail.com",
//                        schoolEmail: "appleapple@wustl.edu",
//                        phone: "111-111-1111",
//                        imageName: "dogProfile",
//                        qrName: "sampleQR"
//                    ),
//                    Contact(
//                        name: "Bear Bear",
//                        schoolInfo: "WashU - Junior",
//                        major: "Biology",
//                        personalEmail: "bearbear@gmail.com",
//                        schoolEmail: "bearbear@wustl.edu",
//                        phone: "222-222-2222",
//                        imageName: "dogProfile",
//                        qrName: "sampleQR"
//                    )
//                ]
//            )
//        ]
//
//        allContacts = [
//            Contact(
//                name: "Orange Orange",
//                schoolInfo: "WashU - Senior",
//                major: "Chemistry",
//                personalEmail: "orangeorange@gmail.com",
//                schoolEmail: "orangeorange@wustl.edu",
//                phone: "555-555-5555",
//                imageName: "dogProfile",
//                qrName: "sampleQR"
//            ),
//            Contact(
//                name: "Bird Bird",
//                schoolInfo: "WashU - Junior",
//                major: "Economics",
//                personalEmail: "birdbird@gmail.com",
//                schoolEmail: "birdbird@wustl.edu",
//                phone: "666-666-6666",
//                imageName: "dogProfile",
//                qrName: "sampleQR"
//            ),
//            Contact(
//                name: "Duck Duck",
//                schoolInfo: "WashU - Sophomore",
//                major: "History",
//                personalEmail: "duckduck@gmail.com",
//                schoolEmail: "duckduck@wustl.edu",
//                phone: "777-777-7777",
//                imageName: "dogProfile",
//                qrName: "sampleQR"
//            ),
//            Contact(
//                name: "Soda Soda",
//                schoolInfo: "WashU - Freshman",
//                major: "Engineering",
//                personalEmail: "sodasoda@gmail.com",
//                schoolEmail: "sodasoda@wustl.edu",
//                phone: "888-888-8888",
//                imageName: "dogProfile",
//                qrName: "sampleQR"
//            )
//        ]
//    }
//}
//    
//    
//    
//    
//    
//    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

