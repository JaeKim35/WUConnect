//
//  ContactsDetailView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/4/26.
//

import SwiftUI
import FirebaseFirestore

struct ContactDetailView: View {
    let contact: Contact
    
    @State private var name = ""
    @State private var schoolInfo = ""
    @State private var major = ""
    @State private var secondMajor = ""

    @State private var personalEmail = ""
    @State private var schoolEmail = ""
    @State private var phone = ""
    
    @State private var imageName = ""
    @State private var qrName = ""
    
    @State private var showPersonalEmail = true
    @State private var showSchoolEmail = true
    @State private var showPhone = true
    
    let database = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                //Top section
                HStack {
                    Text(schoolInfo)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer().frame(height: 55)

                
                //Name + image
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text(major)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    AsyncImage(url: URL(string: imageName)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 130, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                }
                .padding(.horizontal, 34)

                Spacer().frame(height: 55)

                
                //contact info
                VStack(spacing: 18) {
                    
                    if showPersonalEmail {
                        InfoData(label: "Email 1", value: personalEmail)
                    }
                    
                    if showSchoolEmail {
                        InfoData(label: "Email 2", value: schoolEmail)
                    }
                    
                    if showPhone {
                        InfoData(label: "Phone", value: phone)
                    }
                    
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 34)

                
                
                //QR title area
                Text("QR Code")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )

                Spacer().frame(height: 20)

                //QR image
                AsyncImage(url: URL(string: qrName)) { image in
                    image
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 230, height: 230)
                .background(Color.white)

                Spacer()
            }
            .onAppear {
                
                print(contact.username)
                
                database
                    .collection("Users")
                    .whereField("username", isEqualTo: contact.username)
                    .limit(to: 1)
                    .getDocuments { (querySnapshot, error) in
                        
                        if let error = error {
                            print("There was an error getting the users:", error)
                            return
                        }
                        
                        guard let querySnapshot = querySnapshot,
                              let document = querySnapshot.documents.first else {
                            return
                        }
                        
                        let contactFetched = document.data()
                        
                        guard let fetchedName = contactFetched["name"] as? String,
                              let fetchedSchoolInfo = contactFetched["schoolInfo"] as? String,
                              let fetchedMajor = contactFetched["major"] as? String,
                              let fetchedSecondMajor = contactFetched["secondMajor"] as? String,
                              let fetchedPersonalEmail = contactFetched["personalEmail"] as? String,
                              let fetchedSchoolEmail = contactFetched["schoolEmail"] as? String,
                              let fetchedPhone = contactFetched["phone"] as? String,
                              let fetchedImageName = contactFetched["imageName"] as? String,
                              let fetchedQrName = contactFetched["qrName"] as? String,
                              let fetchedShowPersonalEmail = contactFetched["showPersonalEmail"] as? Bool,
                              let fetchedShowSchoolEmail = contactFetched["showSchoolEmail"] as? Bool,
                              let fetchedShowPhone = contactFetched["showPhone"] as? Bool else {
                            print("There was an error reading the user data.")
                            return
                        }
                        
                        name = fetchedName
                        schoolInfo = fetchedSchoolInfo
                        name = fetchedName
                        schoolInfo = fetchedSchoolInfo
                        major = fetchedMajor
                        secondMajor = fetchedSecondMajor
                        personalEmail = fetchedPersonalEmail
                        schoolEmail = fetchedSchoolEmail
                        phone = fetchedPhone
                        imageName = fetchedImageName
                        qrName = fetchedQrName
                        showPersonalEmail = fetchedShowPersonalEmail
                        showSchoolEmail = fetchedShowSchoolEmail
                        showPhone = fetchedShowPhone
                        
                    }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}




#Preview {
    NavigationStack {
        ContactDetailView(
            contact: Contact(
                username: "Edgar",
                name: "Apple Apple",
                schoolInfo: "WashU - Senior",
                major: "Computer Science",
                personalEmail: "appleapple@gmail.com",
                schoolEmail: "appleapple@wustl.edu",
                phone: "999-999-9999",
                imageName: "dogProfile",
                qrName: "sampleQR"
            )
        )
    }
}
