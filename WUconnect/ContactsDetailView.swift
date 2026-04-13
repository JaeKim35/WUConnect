//
//  ContactsDetailView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/4/26.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: Contact

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                //Top section
                HStack {
                    Text(contact.schoolInfo)
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
                        Text(contact.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text(contact.major)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Image(contact.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 34)

                Spacer().frame(height: 55)

                
                //contact info
                VStack(spacing: 18) {
                    InfoData(label: "Email", value: contact.personalEmail)
                    InfoData(label: "Email", value: contact.schoolEmail)
                    InfoData(label: "Phone", value: contact.phone)
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
                Image(contact.qrName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .background(Color.white)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}




#Preview {
    NavigationStack {
        ContactDetailView(
            contact: Contact(
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
