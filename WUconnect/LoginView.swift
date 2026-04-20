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
                    
                    database
                        .collection("Users")
                        .whereField("username", isEqualTo: username)
                        .limit(to: 1)
                        .getDocuments { (querySnapshot, error) in
                            
                            if let error = error {
                                print("There was an error getting the users:", error)
                                return
                            }
                            
                            let userFetched = querySnapshot!.documents.first!.data()
                            
                            do {
                                
                                let correctPassword = try BCrypt.Hash.verify(message: password, matches: userFetched["password"] as! String)
                                
                                if !correctPassword {
                                    wrongPasswordAlert = true
                                    return
                                }
                                
                                let user = User(
                                    username: userFetched["username"] as! String,
                                    name: userFetched["name"] as! String,
                                    schoolInfo: userFetched["schoolInfo"] as! String,
                                    major: userFetched["major"] as! String,
                                    secondMajor: userFetched["secondMajor"] as! String,
                                    personalEmail: userFetched["personalEmail"] as! String,
                                    schoolEmail: userFetched["schoolEmail"] as! String,
                                    phone: userFetched["phone"] as! String,
                                    imageName: userFetched["imageName"] as! String,
                                    qrName: userFetched["qrName"] as! String,
                                    showPersonalEmail: userFetched["showPersonalEmail"] as! Bool,
                                    showSchoolEmail: userFetched["showSchoolEmail"] as! Bool,
                                    showPhone: userFetched["showPhone"] as! Bool
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
                                
                                if querySnapshot!.count == 1 {
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
                                            "name": "Dog Dog",
                                            "schoolInfo": "WashU - Senior",
                                            "major": "Computer Science",
                                            "secondMajor": "",
                                            "personalEmail": "aaaaaaa@gmail.com",
                                            "schoolEmail": "aaaaaaa@wustl.edu",
                                            "phone": "999-999-9999",
                                            "imageName": "",
                                            "qrName": "",
                                            "showPersonalEmail": true,
                                            "showSchoolEmail": true,
                                            "showPhone": true
                                        ])
                                    
                                    let document = try QRCode.Document(utf8String: username)
                                    
                                    let profilePicture = UIImage(named: "dogProfile")?.jpegData(compressionQuality: 0.8)
                                    
                                    let profilePictureReference = storage.reference().child("\(username)_PFP.jpg")
                                    
                                    profilePictureReference.putData(profilePicture!) { _, error in
                                    
                                        if let error = error {
                                            print("There was an error uploading the profile picture:", error)
                                            return
                                        }
                                        
                                        profilePictureReference.downloadURL() { url, error in
                                            
                                            if let error = error {
                                                print("There was an error getting the URL:", error)
                                                return
                                            }
                                            
                                            documentID.updateData(["imageName": url!.absoluteString])
                                            
                                        }
                                        
                                    }
                                    
                                    let QRCode = try document.pngData(dimension: 400)
                                    
                                    let QRCodeReference = storage.reference().child("\(username)_QR.png")
                                    
                                    QRCodeReference.putData(QRCode) { _, error in
                                        
                                        if let error = error {
                                            print("There was an error uploading the QR code:", error)
                                            return
                                        }
                                        
                                        QRCodeReference.downloadURL() { url, error in
                                            
                                            if let error = error {
                                                print("There was an error getting the URL:", error)
                                                return
                                            }
                                            
                                            documentID.updateData(["qrName": url!.absoluteString])
                                            
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
