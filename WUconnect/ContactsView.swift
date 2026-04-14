//
//  ContactsView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var appState: AppState

    //Fake data for now
    @State private var contactGroups: [ContactGroup] = [
        ContactGroup(
            name: "CSE 4308",
            contacts: [
                Contact(
                    name: "Apple Apple",
                    schoolInfo: "WashU - Senior",
                    major: "Computer Science",
                    personalEmail: "appleapple@gmail.com",
                    schoolEmail: "appleapple@wustl.edu",
                    phone: "111-111-1111",
                    imageName: "dogProfile",
                    qrName: "sampleQR"
                ),
                Contact(
                    name: "Bear Bear",
                    schoolInfo: "WashU - Junior",
                    major: "Biology",
                    personalEmail: "bearbear@gmail.com",
                    schoolEmail: "bearbear@wustl.edu",
                    phone: "222-222-2222",
                    imageName: "dogProfile",
                    qrName: "sampleQR"
                ),
                Contact(
                    name: "Cat Cat",
                    schoolInfo: "WashU - Sophomore",
                    major: "Mathematics",
                    personalEmail: "catcat@gmail.com",
                    schoolEmail: "catcat@wustl.edu",
                    phone: "333-333-3333",
                    imageName: "dogProfile",
                    qrName: "sampleQR"
                ),
                Contact(
                    name: "Pear Pear",
                    schoolInfo: "WashU - Freshman",
                    major: "Physics",
                    personalEmail: "pearpear@gmail.com",
                    schoolEmail: "pearpear@wustl.edu",
                    phone: "444-444-4444",
                    imageName: "dogProfile",
                    qrName: "sampleQR"
                )
            ]
        )
    ]

    let allContacts: [Contact] = [
        Contact(
            name: "Orange Orange",
            schoolInfo: "WashU - Senior",
            major: "Chemistry",
            personalEmail: "orangeorange@gmail.com",
            schoolEmail: "orangeorange@wustl.edu",
            phone: "555-555-5555",
            imageName: "dogProfile",
            qrName: "sampleQR"
        ),
        Contact(
            name: "Bird Bird",
            schoolInfo: "WashU - Junior",
            major: "Economics",
            personalEmail: "birdbird@gmail.com",
            schoolEmail: "birdbird@wustl.edu",
            phone: "666-666-6666",
            imageName: "dogProfile",
            qrName: "sampleQR"
        ),
        Contact(
            name: "Duck Duck",
            schoolInfo: "WashU - Sophomore",
            major: "History",
            personalEmail: "duckduck@gmail.com",
            schoolEmail: "duckduck@wustl.edu",
            phone: "777-777-7777",
            imageName: "dogProfile",
            qrName: "sampleQR"
        ),
        Contact(
            name: "Soda Soda",
            schoolInfo: "WashU - Freshman",
            major: "Engineering",
            personalEmail: "sodasoda@gmail.com",
            schoolEmail: "sodasoda@wustl.edu",
            phone: "888-888-8888",
            imageName: "dogProfile",
            qrName: "sampleQR"
        )
    ]

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

                        //Grouped contacts
                        ForEach(contactGroups) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.name)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)

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
                                            ContactRow(contact: contact)

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
                        }

                        //All contacts
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contacts")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)

                            VStack(spacing: 0) {
                                ForEach(allContacts) { contact in
                                    ContactRow(contact: contact)

                                    if contact.id != allContacts.last?.id {
                                        Divider()
                                            .background(Color.white.opacity(0.15))
                                            .padding(.horizontal, 14)
                                    }
                                }

                                Text("...")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            .background(Color(red: 0.38, green: 0.34, blue: 0.40).opacity(0.6))
                            .cornerRadius(16)
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

    //Create a new group
    func createGroup() {
        let trimmedName = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            return
        }

        contactGroups.append(
            ContactGroup(
                name: trimmedName,
                contacts: []
            )
        )

        newGroupName = ""
        showCreateGroupSheet = false
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

    var body: some View {
        NavigationStack {
            ContactsView()
                .environmentObject(appState)
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
