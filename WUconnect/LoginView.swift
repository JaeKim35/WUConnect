//
//  LoginView.swift
//  WUconnect
//
//  Created by Jaeyeon Kim on 4/3/26.
//


import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import BCrypt
import QRCode

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var wrongPasswordAlert = false
    @State private var userNotFoundAlert = false
    @State private var usernameTakenAlert = false
    @State private var userCreatedAlert = false
    
    let database = Firestore.firestore()
    let storage = Storage.storage()

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
                
                Text("New Here?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Text("Enter a username and password, then tap Sign Up.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

                Text("Login to your Account")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 5)

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
                    
                    database
                        .collection("Users")
                        .whereField("username", isEqualTo: username)
                        .limit(to: 1)
                        .getDocuments { (querySnapshot, error) in
                            
                            if let error = error {
                                print("There was an error getting the users:", error)
                                return
                            }
                            
                            guard let querySnapshot = querySnapshot,
                                  let document = querySnapshot.documents.first else {
                                userNotFoundAlert = true
                                return
                            }

                            let userFetched = document.data()
                            
                            guard let storedPassword = userFetched["password"] as? String,
                                  let fetchedUsername = userFetched["username"] as? String,
                                  let fetchedName = userFetched["name"] as? String,
                                  let fetchedSchoolInfo = userFetched["schoolInfo"] as? String,
                                  let fetchedMajor = userFetched["major"] as? String,
                                  let fetchedSecondMajor = userFetched["secondMajor"] as? String,
                                  let fetchedPersonalEmail = userFetched["personalEmail"] as? String,
                                  let fetchedSchoolEmail = userFetched["schoolEmail"] as? String,
                                  let fetchedPhone = userFetched["phone"] as? String,
                                  let fetchedImageName = userFetched["imageName"] as? String,
                                  let fetchedQrName = userFetched["qrName"] as? String,
                                  let fetchedShowPersonalEmail = userFetched["showPersonalEmail"] as? Bool,
                                  let fetchedShowSchoolEmail = userFetched["showSchoolEmail"] as? Bool,
                                  let fetchedShowPhone = userFetched["showPhone"] as? Bool else {
                                print("There was an error reading the user data.")
                                return
                            }
                            
                            do {
                                
                                let correctPassword = try BCrypt.Hash.verify(message: password, matches: storedPassword)
                                
                                if !correctPassword {
                                    wrongPasswordAlert = true
                                    return
                                }
                                
                                let user = User(
                                    username: fetchedUsername,
                                    name: fetchedName,
                                    schoolInfo: fetchedSchoolInfo,
                                    major: fetchedMajor,
                                    secondMajor: fetchedSecondMajor,
                                    personalEmail: fetchedPersonalEmail,
                                    schoolEmail: fetchedSchoolEmail,
                                    phone: fetchedPhone,
                                    imageName: fetchedImageName,
                                    qrName: fetchedQrName,
                                    showPersonalEmail: fetchedShowPersonalEmail,
                                    showSchoolEmail: fetchedShowSchoolEmail,
                                    showPhone: fetchedShowPhone
                                )
                                
                                if rememberMe {
                                    appState.saveUser(user)
                                } else {
                                    appState.currentUser = user
                                }
                                
                            } catch {
                                print("There was an error checking the password hash:", error)
                            }
                            
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
                .disabled(username.isEmpty || password.isEmpty)
                .alert("Wrong Password!", isPresented: $wrongPasswordAlert) {
                    Button("OK", role: ButtonRole.cancel) { }
                } message: {
                    Text("Please try again.")
                }
                .alert("User Not Found", isPresented: $userNotFoundAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("No account exists with this username.")
                }

                Spacer()

                //Don't have an account part
                HStack(spacing: 6) {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                        .font(.system(size: 16))

                    Button("Sign Up") {
                        
                        database
                            .collection("Users")
                            .whereField("username", isEqualTo: username)
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
                                    usernameTakenAlert = true
                                    return
                                }
                                
                                do {
                                    
                                    let hashedPassword = try BCrypt.Hash.make(message: password)
                                    
                                    let documentID = database
                                        .collection("Users")
                                        .addDocument(data: [
                                            "username": username,
                                            "password": hashedPassword.makeString(),
                                            "name": "Name?",
                                            "schoolInfo": "WashU - Academic Year?",
                                            "major": "Major?",
                                            "secondMajor": "",
                                            "personalEmail": "Personal Email?",
                                            "schoolEmail": "School Email?",
                                            "phone": "Phone Number?",
                                            "imageName": "dogProfile",
                                            "qrName": "",
                                            "showPersonalEmail": true,
                                            "showSchoolEmail": true,
                                            "showPhone": true
                                        ])
                                    
                                    let document = try QRCode.Document(utf8String: username)
                                    
                                    if let profilePicture = UIImage(named: "dogProfile")?.jpegData(compressionQuality: 0.8) {
                                        
                                        let profilePictureReference = storage.reference().child("\(username)_PFP.jpg")
                                        
                                        profilePictureReference.putData(profilePicture) { _, error in
                                            
                                            if let error = error {
                                                print("There was an error uploading the profile picture:", error)
                                                return
                                            }
                                            
                                            profilePictureReference.downloadURL() { url, error in
                                                
                                                if let error = error {
                                                    print("There was an error getting the URL:", error)
                                                    return
                                                }
                                                
                                                guard let url = url else {
                                                    print("There was an error getting the URL.")
                                                    return
                                                }
                                                
                                                documentID.updateData(["imageName": url.absoluteString])
                                                
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    let qrCodeData = try document.pngData(dimension: 400)
                                    
                                    let qrCodeReference = storage.reference().child("\(username)_QR.png")
                                    
                                    qrCodeReference.putData(qrCodeData) { _, error in
                                        
                                        if let error = error {
                                            print("There was an error uploading the QR code:", error)
                                            return
                                        }
                                        
                                        qrCodeReference.downloadURL() { url, error in
                                            
                                            if let error = error {
                                                print("There was an error getting the URL:", error)
                                                return
                                            }
                                            
                                            guard let url = url else {
                                                print("There was an error getting the URL.")
                                                return
                                            }
                                            
                                            documentID.updateData(["qrName": url.absoluteString])

                                            if var currentUser = appState.currentUser {
                                                currentUser.qrName = url.absoluteString
                                                appState.updateUser(currentUser)
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    userCreatedAlert = true
                                    
                                } catch {
                                    print("There was an error hashing the password or generating the QR code:", error)
                                }
                                
                            }
                        
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                    .disabled(username.isEmpty || password.isEmpty)
                    .alert("Username Taken!", isPresented: $usernameTakenAlert) {
                        Button("OK", role: ButtonRole.cancel) { }
                    } message: {
                        Text("Please choose a different username.")
                    }
                    .alert("Username Created!", isPresented: $userCreatedAlert) {
                        Button("OK", role: ButtonRole.cancel) { }
                    } message: {
                        Text("You can log in now.")
                    }
                    
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
