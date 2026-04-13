//
//  LoginView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        ZStack {
            //Dark Mode by default(fixed)
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer()

                //Title Area
                Text("WUconnect")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.white)

                Text("Login to your Account")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Spacer()

                //Input Area
                //using Username instead of email to make things easier
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Username")
                            .foregroundColor(.white)
                            .font(.system(size: 18))

                        TextField("", text: $username)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 42)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.never)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .foregroundColor(.white)
                            .font(.system(size: 18))

                        SecureField("", text: $password)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 42)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }

                    //Remember Me
                    Toggle(isOn: $rememberMe) {
                        Text("Remember me")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                    .toggleStyle(CheckBox())
                }
                .padding(.horizontal, 50)

                Spacer()

                //Login Button
                Button(action: {
                    print("Login tapped")

                    let user = User(
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

                    if rememberMe {
                        appState.saveUser(user)
                    } else {
                        appState.currentUser = user
                    }
                }) {
                    Text("Login")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(Color.blue)
                        .cornerRadius(24)
                }
                .padding(.horizontal, 32)

                Spacer()

                //Don't have an account part
                HStack(spacing: 6) {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                        .font(.system(size: 16))

                    Button("Sign Up") {
                        print("Sign Up tapped")
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(.bottom, 30)
            }
        }
    }
}

//Remember Me Checkbox settings
struct CheckBox: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                    .overlay {
                        if configuration.isOn {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }

                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
