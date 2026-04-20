//
//  GroupDetailView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/13/26.
//

import SwiftUI
import FirebaseFirestore

struct GroupDetailView: View {
    @EnvironmentObject var contactsStore: ContactsStore
    @Environment(\.dismiss) var dismiss

    let groupId: UUID

    @State private var showEditGroupSheet = false

    var body: some View{
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()
            
            if let group = contactsStore.group(for: groupId) {
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: 20)
                    
                    //Group title area
                    Text(group.name)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                    
                    Spacer().frame(height: 24)
                    
                    //Members section
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Members")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("\(group.contacts.count) member\(group.contacts.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        
                        if group.contacts.isEmpty {
                            Text("No contacts in this group")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                .cornerRadius(16)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(group.contacts) { contact in
                                    GroupMemberRow(contact: contact)
                                    
                                    if contact.id != group.contacts.last?.id {
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
                    
                    Spacer()
                }
                .toolbar {
                    //Edit group button
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Edit") {
                            showEditGroupSheet = true
                        }
                        .foregroundColor(.white)
                    }

                    //Manage members button
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(
                            destination: GroupMembersView(groupId: groupId, groupName: group.name)
                        ) {
                            Text("Manage")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $showEditGroupSheet) {
                    EditGroupSheet(groupId: groupId, groupName: group.name)
                        .environmentObject(contactsStore)
                }
            } else {
                EmptyView()
            }
        }
        .navigationTitle("Group")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: contactsStore.contactGroups) { _, _ in
            if contactsStore.group(for: groupId) == nil {
                dismiss()
            }
        }
    }
}


//Row used for members already inside a group
struct GroupMemberRow: View {
    let contact: Contact

    var body: some View {
        NavigationLink(destination: ContactDetailView(contact: contact)) {
            Text(contact.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}


//Sheet for renaming or deleting a group
struct EditGroupSheet: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contactsStore: ContactsStore
    @Environment(\.dismiss) var dismiss

    let groupId: UUID
    let groupName: String

    @State private var editedGroupName = ""
    
    @State private var sameNameAlert = false
    @State private var nameUnavailableAlert = false
    
    let database = Firestore.firestore()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Group Info")) {
                    TextField("Group Name", text: $editedGroupName)
                }

                Section {
                    Button("Save Name Change") {
                        
                        if editedGroupName == groupName {
                            sameNameAlert = true
                            return
                        }
                        
                        if let user = appState.currentUser {
                            
                            database
                                .collection("Contact Groups")
                                .whereField("username", isEqualTo: user.username)
                                .whereField("name", isEqualTo: editedGroupName)
                                .limit(to: 1)
                                .getDocuments { (querySnapshot, error) in
                                    
                                    if let error = error {
                                        print("There was an error getting the users:", error)
                                        return
                                    }
                                    
                                    guard let querySnapshot = querySnapshot else {
                                        print("There was an error getting the users.")
                                        return
                                    }
                                    
                                    if querySnapshot.count == 1 {
                                        nameUnavailableAlert = true
                                        return
                                    }
                                    
                                    database
                                        .collection("Contact Groups")
                                        .whereField("username", isEqualTo: user.username)
                                        .whereField("name", isEqualTo: groupName)
                                        .limit(to: 1)
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
                                            
                                            documentID.updateData(["name": editedGroupName])
                                            
                                            contactsStore.renameGroup(
                                                groupId: groupId,
                                                newName: editedGroupName
                                            )
                                            
                                            DispatchQueue.main.async {
                                                dismiss()
                                            }
                                            
                                        }
                                    
                                }
                            
                        }
                        
                    }
                }

                Section {
                    Button(role: .destructive) {
                        
                        contactsStore.deleteGroup(groupId: groupId)
                        
                        if let user = appState.currentUser {
                            
                            database
                                .collection("Contact Groups")
                                .whereField("username", isEqualTo: user.username)
                                .whereField("name", isEqualTo: groupName)
                                .limit(to: 1)
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
                                    
                                    documentID.delete()
                                    
                                }
                            
                        }
                        
                        dismiss()
                        
                    } label: {
                        Text("Delete Group")
                    }
                }
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let group = contactsStore.group(for: groupId) {
                    editedGroupName = group.name
                }
            }
            .alert("Same Name!", isPresented: $sameNameAlert) {
                Button("OK", role: ButtonRole.cancel) { }
            } message: {
                Text("Please choose a different name.")
            }
            .alert("Name Unavailable!", isPresented: $nameUnavailableAlert) {
                Button("OK", role: ButtonRole.cancel) { }
            } message: {
                Text("Please choose a different name.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(groupId: UUID())
            .environmentObject(ContactsStore())
    }
}
