//
//  ProfileView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            if let user = appState.currentUser {
                VStack(spacing: 0) {

                    //Top section
                    HStack(alignment: .center, spacing: 12) {
                        Text(user.schoolInfo)
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
                        VStack(alignment: .leading, spacing: 12) {

                            Text(user.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(user.major)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        //prof pic
                        Image(user.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 55)

                    //contact info
                    VStack(spacing: 18) {
                        if user.showPersonalEmail {
                            InfoData(label: "Email", value: user.personalEmail)
                        }

                        if user.showSchoolEmail {
                            InfoData(label: "Email", value: user.schoolEmail)
                        }

                        if user.showPhone {
                            InfoData(label: "Phone", value: user.phone)
                        }
                    }
                    .padding(.horizontal, 34)

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
                    Image(user.qrName)
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
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let appState = AppState()
    appState.currentUser = User(
        name: "Dog Dog",
        schoolInfo: "WashU - Senior",
        major: "Computer Science",
        personalEmail: "aaaaaaa@gmail.com",
        schoolEmail: "aaaaaaa@wustl.edu",
        phone: "999-999-9999",
        imageName: "dogProfile",
        qrName: "sampleQR",
        showPersonalEmail: true,
        showSchoolEmail: true,
        showPhone: true
    )

    return NavigationStack {
        ProfileView()
            .environmentObject(appState)
    }
}
