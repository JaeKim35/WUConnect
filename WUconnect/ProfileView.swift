//
//  ProfileView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI

struct ProfileView: View {
    //Using fake data for now
    //using WashU because full school name would make font too small
    let schoolInfo = "WashU - Senior"
    let name = "Dog Dog"
    let major = "Computer Science"
    let personalEmail = "aaaaaaa@gmail.com"
    let schoolEmail = "aaaaaaa@wustl.edu"
    let phone = "999-999-9999"

    
    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                //Top section
                HStack(alignment: .center, spacing: 12) {
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

                    //settings
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
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
                    //prof pic
                    Image("dogProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 34)

                Spacer().frame(height: 55)

                
                //contact info
                VStack(spacing: 18) {
                    InfoRow(label: "Email", value: personalEmail)
                    InfoRow(label: "Email", value: schoolEmail)
                    InfoRow(label: "Phone", value: phone)
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

                //QR image (temporary)
                Image("sampleQR")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .background(Color.white)

                Spacer()

                //contacts & calendar buttons
                HStack {
                    NavigationLink(destination: ContactsView()) {
                        Text("Contacts")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }

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
        .navigationBarBackButtonHidden(true)
    }
}



struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
