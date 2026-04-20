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

                            Text("\(user.name) (\(user.username))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(user.major)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)

                            if !user.secondMajor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(user.secondMajor)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        // ✅ FIXED PROFILE IMAGE
                        Group {
                            if user.imageName.starts(with: "http") {
                                AsyncImage(url: URL(string: user.imageName)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(user.imageName)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 55)

                    //contact info
                    VStack(spacing: 18) {
                        if user.showPersonalEmail {
                            InfoData(label: "Email 1", value: user.personalEmail)
                        }

                        if user.showSchoolEmail {
                            InfoData(label: "Email 2", value: user.schoolEmail)
                        }

                        if user.showPhone {
                            InfoData(label: "Phone", value: user.phone)
                        }
                    }
                    .padding(.horizontal, 34)

                    Spacer().frame(height: 34)

                    //QR title
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

                    // ✅ FIXED QR CODE DISPLAY
                    Group {
                        if user.qrName.starts(with: "http") {
                            AsyncImage(url: URL(string: user.qrName)) { image in
                                image
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "qrcode")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)

                                Text("QR not ready")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(width: 230, height: 230)
                    .background(Color.white)

                    Spacer()

                    //Bottom buttons
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
