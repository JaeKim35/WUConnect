//
//  ContactsView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contactsStore: ContactsStore
    
    @State private var searchText = ""
    @State private var showCreateGroupSheet = false
    @State private var newGroupName = ""

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //Top title area
                Text("Contacts")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .padding(.top, 24)
                
                Spacer().frame(height: 22)
                
                //Search + create group area
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Find", text: $searchText)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 36)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(8)
                    
                    Button(action: {
                        showCreateGroupSheet = true
                    }) {
                        Text("Create Group")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 36)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        //Groups section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Groups")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            if filteredGroups.isEmpty {
                                Text("No matching groups")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                    .cornerRadius(16)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(filteredGroups) { group in
                                        NavigationLink(
                                            destination: GroupDetailView(groupId: group.id)
                                        ) {
                                            GroupRow(group: group)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if group.id != filteredGroups.last?.id {
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
                        
                        //All contacts section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contacts")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            if filteredAllContacts.isEmpty {
                                Text("No matching contacts")
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                                    .cornerRadius(16)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(filteredAllContacts) { contact in
                                        ContactRow(contact: contact)
                                        
                                        if contact.id != filteredAllContacts.last?.id {
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                }
                
                Spacer()
                
                //Bottom buttons
                HStack {
                    profileButton
                    
                    Spacer()
                    
                    NavigationLink(destination: CalendarView()) {
                        Text("Calendar")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCreateGroupSheet) {
            CreateGroupSheet(
                groupName: $newGroupName,
                onSave: {
                    createGroup()
                }
            )
        }
    }
    
    
    @ViewBuilder
    var profileButton: some View {
        if appState.currentUser != nil {
            NavigationLink(destination: ProfileView()) {
                Text("Profile")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
            }
        } else {
            EmptyView()
        }
    }
    
    
    //search text
    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //filter groups by group name
    var filteredGroups: [ContactGroup] {
        if trimmedSearchText.isEmpty {
            return contactsStore.contactGroups
        }
        
        let lowercasedSearch = trimmedSearchText.lowercased()
        
        return contactsStore.contactGroups.filter { group in
            group.name.lowercased().contains(lowercasedSearch)
        }
    }
    
    //filtering all contacts section by name
    var filteredAllContacts: [Contact] {
        if trimmedSearchText.isEmpty {
            return contactsStore.allContacts
        }
        
        let lowercasedSearch = trimmedSearchText.lowercased()
        
        return contactsStore.allContacts.filter { contact in
            contact.name.lowercased().contains(lowercasedSearch)
        }
    }
    
    
    //Create a new group
    func createGroup() {
        contactsStore.createGroup(name: newGroupName)
        newGroupName = ""
        showCreateGroupSheet = false
    }
    
}


//Row used for groups on the main contacts page
struct GroupRow: View {
    let group: ContactGroup
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                
                Text("\(group.contacts.count) member\(group.contacts.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}


struct ContactRow: View {
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


//creating a new group
struct CreateGroupSheet: View {
    @Binding var groupName: String
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Group Info")) {
                    TextField("Group Name", text: $groupName)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

struct ContactsView_PreviewWrapper: View {
    @StateObject private var appState = AppState()
    @StateObject private var contactsStore = ContactsStore()

    var body: some View {
        NavigationStack {
            ContactsView()
                .environmentObject(appState)
                .environmentObject(contactsStore)
        }
        .onAppear {
            appState.currentUser = User(
                name: "Dog Dog",
                schoolInfo: "WashU - Senior",
                major: "Computer Science",
                secondMajor: "",
                personalEmail: "aaaaaaa@gmail.com",
                schoolEmail: "aaaaaaa@wustl.edu",
                phone: "999-999-9999",
                imageName: "dogProfile",
                qrName: "sampleQR",
                showPersonalEmail: true,
                showSchoolEmail: true,
                showPhone: true
            )
        }
    }
}

#Preview {
    ContactsView_PreviewWrapper()
}
