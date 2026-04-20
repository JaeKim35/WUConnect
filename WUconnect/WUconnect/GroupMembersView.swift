//
//  GroupMembersView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/13/26.
//

import SwiftUI
import FirebaseFirestore

struct GroupMembersView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contactsStore: ContactsStore
    @Environment(\.dismiss) var dismiss

    let groupId: UUID
    let groupName: String

    //Track selected contacts (multi-select)
    @State private var selectedContacts: Set<UUID> = []
    
    let database = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer().frame(height: 20)

                //Title
                Text("Manage Members")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )

                Spacer().frame(height: 24)
                
                //Helper line
                Text("Checked contacts will be included in this group.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                //All contacts section
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Contacts")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)

                        if contactsStore.allContacts.isEmpty {
                            Text("No contacts available")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                .cornerRadius(16)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(contactsStore.allContacts) { contact in
                                    SelectableContactRow(
                                        contact: contact,
                                        isSelected: selectedContacts.contains(contact.id),
                                        onTap: {
                                            toggleSelection(contact.id)
                                        }
                                    )

                                    if contact.id != contactsStore.allContacts.last?.id {
                                        Divider()
                                            .background(Color.white.opacity(0.15))
                                            .padding(.horizontal, 14)
                                    }
                                }
                            }
                            .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                //Save changes button
                Button(action: {
                    saveGroupMembers()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Group Members")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentMembers()
        }
    }

    //Load existing group members as selected
    func loadCurrentMembers() {
        guard let group = contactsStore.group(for: groupId) else {
            return
        }

        selectedContacts = Set(group.contacts.map { $0.id })
    }

    //Toggle selection on/off
    func toggleSelection(_ id: UUID) {
        if selectedContacts.contains(id) {
            selectedContacts.remove(id)
        } else {
            selectedContacts.insert(id)
        }
    }

    //Save the full member list back into the group
    func saveGroupMembers() {
        
        let updatedContacts = contactsStore.allContacts.filter { contact in
            selectedContacts.contains(contact.id)
        }

        contactsStore.updateGroupMembers(
            groupId: groupId,
            newContacts: updatedContacts
        )
        
        let selectedUsernames = contactsStore.allContacts
            .filter { selectedContacts.contains($0.id) }
            .map { ["username": $0.username, "name": $0.name] }
        
        if let user = appState.currentUser {
            
            database
                .collection("Contact Groups")
                .whereField("username", isEqualTo: user.username)
                .whereField("name", isEqualTo: groupName)
                .getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        print("There was an error getting the contact groups:", error)
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot,
                          let document = querySnapshot.documents.first else {
                        print("There was an error finding the contact group document.")
                        return
                    }
                    
                    let documentID = database.collection("Contact Groups").document(document.documentID)
                    
                    documentID.updateData(["contacts": selectedUsernames])
                    
                }
            
        }

        dismiss()
    }
}


//Selectable row with checkmark(used to add or remove from group)
struct SelectableContactRow: View {
    let contact: Contact
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(contact.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
