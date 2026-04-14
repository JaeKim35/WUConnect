//
//  SettingsView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var major = ""

    @State private var personalEmail = ""
    @State private var schoolEmail = ""
    @State private var phone = ""

    @State private var showPersonalEmail = true
    @State private var showSchoolEmail = true
    @State private var showPhone = true

    @State private var validationMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            if let user = appState.currentUser {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        //Profile photo area
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Profile Photo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 16) {
                                Image(user.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))

                                Button(action: {
                                    print("Change Profile Photo tapped")
                                }) {
                                    Text("Change Profile Photo")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.12))
                                        .cornerRadius(8)
                                }
                            }
                        }

                        //Profile info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Profile Info")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsInputField(
                                title: "Name",
                                text: $name,
                                keyboardType: UIKeyboardType.default
                            )
                            
                            
                            //major field
                            SettingsInputField(
                                title: "Major",
                                text: $major,
                                keyboardType: UIKeyboardType.default
                            )
                        }
    

                        //Edit contact info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Edit Contact Info")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsInputField(
                                title: "Personal Email",
                                text: $personalEmail,
                                keyboardType: UIKeyboardType.emailAddress
                            )

                            SettingsInputField(
                                title: "School Email",
                                text: $schoolEmail,
                                keyboardType: UIKeyboardType.emailAddress
                            )

                            SettingsInputField(
                                title: "Phone Number",
                                text: $phone,
                                keyboardType: UIKeyboardType.phonePad
                            )
                        }

                        //Privacy settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Privacy Settings")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            SettingsToggleRow(
                                title: "Show Personal Email",
                                isOn: $showPersonalEmail
                            )

                            SettingsToggleRow(
                                title: "Show School Email",
                                isOn: $showSchoolEmail
                            )

                            SettingsToggleRow(
                                title: "Show Phone Number",
                                isOn: $showPhone
                            )
                        }

                        //Validation message
                        if !validationMessage.isEmpty {
                            Text(validationMessage)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                        }

                        //Save button
                        Button(action: {
                            saveSettings()
                        }) {
                            Text("Save Changes")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        //Logout button
                        Button(action: {
                            appState.logout()
                        }) {
                            Text("Logout")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
                .onAppear {
                    name = user.name
                    major = user.major
                    personalEmail = user.personalEmail
                    schoolEmail = user.schoolEmail
                    phone = user.phone
                    showPersonalEmail = user.showPersonalEmail
                    showSchoolEmail = user.showSchoolEmail
                    showPhone = user.showPhone
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    
    func saveSettings() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMajor = major.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPersonalEmail = personalEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSchoolEmail = schoolEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            validationMessage = "Name cannot be empty."
            return
        }

        
        if trimmedMajor.isEmpty {
                    validationMessage = "Major cannot be empty."
                    return
                }
        
        if !trimmedPersonalEmail.isEmpty && !isValidEmail(trimmedPersonalEmail) {
            validationMessage = "Please enter a valid personal email."
            return
        }

        if !trimmedSchoolEmail.isEmpty && !isValidEmail(trimmedSchoolEmail) {
            validationMessage = "Please enter a valid school email."
            return
        }

        if !trimmedPhone.isEmpty && !isValidPhone(trimmedPhone) {
            validationMessage = "Please enter a valid phone number."
            return
        }

        if !showPersonalEmail && !showSchoolEmail && !showPhone {
            validationMessage = "Please leave at least one contact item visible."
            return
        }

        guard var user = appState.currentUser else {
            return
        }

        
        //updating user info
        user.name = trimmedName
        user.major = trimmedMajor
        user.personalEmail = trimmedPersonalEmail
        user.schoolEmail = trimmedSchoolEmail
        user.phone = trimmedPhone

        user.showPersonalEmail = showPersonalEmail
        user.showSchoolEmail = showSchoolEmail
        user.showPhone = showPhone

        validationMessage = ""
        appState.updateUser(user)
        dismiss()
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailPattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }

    func isValidPhone(_ phone: String) -> Bool {
        let digitsOnly = phone.filter { $0.isNumber }
        return digitsOnly.count >= 10
    }
}



struct SettingsInputField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            TextField("", text: $text)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
                )
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
        }
    }
}



struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}
